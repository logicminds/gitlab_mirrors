#!/usr/bin/env ruby
#Author: Corey Osman
#Email : corey@bodeco.io
#Date  : 1/6/2015
#Purpose : Auto adds/syncs the mirror list from a given yaml file and populates the gitlab-mirrors list
# requires: the path to the gitlab-mirrors repo, and the path to the mirror list yaml file
# Example mirror_list.yaml file
#---
#puppet-vagrant: https://github.com/boxen/puppet-vagrant.git
#puppet-sudo: https://github.com/saz/puppet-sudo.git
#puppetlabs-inifile: https://github.com/puppetlabs/puppetlabs-inifile.git

require 'yaml'
require 'logger'

if ARGV.size < 2
  puts "Please supply the gitlab-mirrors repo directory"
  puts "Usage: #{__FILE__} gitlab-mirrors_repo_dir mirror_list.yaml"
  exit -1
end

@gitlab_mirrors_dir= ARGV[0]

def validate_gitlab_mirrors_dir
  File.exists?(File.join(@gitlab_mirrors_dir, 'config.sh'))
end

if not validate_gitlab_mirrors_dir
   puts "Invalid gitlab-mirrors directory, no config.sh"
   puts "Please supply the gitlab-mirrors repo directory"
   puts "Usage: #{__FILE__} gitlab-mirrors_repo_dir mirror_list.yaml"
   exit -1
end

def logger(level=Logger::INFO)
  if @logger.nil?
    @logger = Logger.new('gitlab-mirror-sync.log', 'weekly')
    @logger.level = level
  end
  @logger
end

def config(file="#{@gitlab_mirrors_dir}/config.sh")
  if @config.nil?
    begin
      data = File.open(file, 'r') {|f| f.readlines }
    rescue
      logger.fatal("Unable to read file: #{file}")
      exit -1
    end
    data = data.find_all{|line| line if line =~ /^\w/ } # clean up any comments or whitespace
    data = data.map{|conf| conf.chomp.split('=') }  # convert key/value data to hash inside an array
    # now convert to hash (compatible with 1.8.7+)
    @config = Hash[data]
  end
  @config
end

@add_mirror_script = "#{@gitlab_mirrors_dir}/add_mirror.sh"
@project_name = config["gitlab_namespace"].gsub("\"", "")
@repo_dir = config["repo_dir"].gsub("\"", "")
@mirror_file = ARGV[1] || "#{@gitlab_mirrors_dir}/mirror_list.yaml"
@ls_repo_script = "#{@gitlab_mirrors_dir}/ls-mirrors.sh"
@git_mirrors = "#{@gitlab_mirrors_dir}/git-mirrors.sh"

# load the mirrors from the list
def mirrors
  if @mirrors.nil?
    begin
      @mirrors = YAML.load_file(@mirror_file)
    rescue
      logger.fatal("Cannot find mirror list at #{@mirror_file} or it is invalid")
      exit -1
    end
  end
  @mirrors
end

def mirror_exists?(name, repo)
  path = File.expand_path(File.join(@repo_dir, @project_name, name))
  logger.debug("Checking if #{path} exists ")
  File.exists?(path)
end

mirrors.each do |name, repo|
  begin
    if not mirror_exists?(name, repo)
      output = `#{@add_mirror_script} --git --project-name #{name} --mirror #{repo} 2>&1`
      logger.info("Adding mirror #{repo}")
      logger.info("#{@add_mirror_script} --git --project-name #{name} --mirror #{repo} 2>&1")
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

