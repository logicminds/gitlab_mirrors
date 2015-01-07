#!/usr/bin/env ruby
#Author: Corey Osman
#Email : corey@bodeco.io
#Date  : 1/6/2015
#Purpose : Auto adds/syncs the mirror list from a given yaml file and populates the gitlab-mirrors list

require 'yaml'
require 'logger'

if ARGV.size < 1
  puts "Please supply the gitlab-mirrors repo directory"
  puts "Usage: #{__FILE__} gitlab-mirrors"
  exit -1
end

@gitlab_mirrors_dir= ARGV.first

if not validate_gitlab_mirrors_dir
   puts "invalide gitlab-mirrors directory found, no config.sh"
   puts "Please supply the gitlab-mirrors repo directory"
   puts "Usage: #{__FILE__} gitlab-mirrors"
   exit -1
end

def validate_gitlab_mirrors_dir
  File.exists?(File.join(@gitlab_mirrors_dir, 'config.sh'))
end

def config(file=@gitlab_mirrors_dir)
  if @config.nil?
    data = File.open('config.sh', 'r') {|f| f.readlines }
    data = data.find_all{|line| line if line =~ /^\w/ } # clean up any comments or whitespace
    @config = data.map{|conf| conf.chomp.split('=') }.to_h  # convert key/value data to hash
  end
  @config
end

@add_mirror_script = "#{@gitlab_mirrors_dir}/add_mirror.sh"
@project_name = config["gitlab_namespace"]
@repo_dir = config["repo_dir"]
@mirror_file = "#{@gitlab_mirrors_dir}/mirror_list.yaml"
@ls_repo_script = "#{@gitlab_mirrors_dir}/ls-mirrors.sh"
@git_mirrors = "#{@gitlab_mirrors_dir}/git-mirrors.sh"

def logger
  if @logger.nil?
    @logger = Logger.new('gitlab-mirror-sync.log', 'weekly')
  end
  @logger
end

# load the mirrors from the list
def mirrors
  if @mirrors.nil?
    begin
      @mirrors = YAML.load_file(@mirror_file)
    rescue
      logger.fatal("Cannot find mirror list at #{@mirror_file} or it is invalid")
      exit -1
      #raise "Cannot find mirror list at #{@mirror_file} or it is invalid"
    end
  end
  @mirrors
end

def existing_mirrors
  @existing_mirrors ||= `#{@ls_repo_script}`
end

def mirror_exists?(name, repo)
   existing_mirrors.include?(name)
end

mirrors.each do |name, repo|
  begin
    if not mirror_exists?(name, repo)
      output = `#{add_mirror_script} --git --project-name #{project_name} --mirror #{repo} 2>&1`
      logger.debug("Adding mirror #{repo}")
      if not $?.success?
        logger.error(output)
      end
    else
       logger.debug("#{repo} is already mirrored")
    end
  rescue Exception => e
    logger.error("An error occured #{e.message}")
  end
end

