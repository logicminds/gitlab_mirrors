require 'spec_helper'
require 'shared_contexts'

describe 'gitlab_mirrors' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera


  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      :mirror_list_repo => 'https://github.com/logicminds/mirror_list.git',
      :mirror_list_repo_path => '/home/gitmirror/mirror_list',
      :gitlab_mirror_user_token => 'abcdefg123456',
      :gitlab_url => "http://192.168.1.1",
      #:gitlab_mirror_user => "gitmirror",
      #:system_mirror_user => "gitmirror",
      #:system_mirror_group => "gitmirror",
      #:system_user_home_dir => "/home/gitmirror",
      #:mirror_repo => "https://github.com/samrocketman/gitlab-mirrors.git",
      #:mirror_repo_dir_name => "gitlab-mirrors",
      #:repositories_dir_name => "repositories",
      #:gitlab_namespace => "gitlab-mirrors",
      #:generate_public_mirrors => true,
      #:ensure_mirror_update_job => present,
      #:prune_mirrors => true,
      #:force_update => true,
      #:ensure_mirror_sync_job => present,
      #:mirrors_list_yaml_file => "mirror_list.yaml",
      #:ensure_mirror_list_repo_cron_job => present,
      #:configure_mirror_list_feature => true,
      :install_dependencies => "true",
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_class('gitlab_mirrors::install_dependencies').
             with({"install_dependencies"=>"true"})
  end
  it do
    is_expected.to contain_class('gitlab_mirrors::config').
             with({"gitlab_mirror_user_token"=>"abcdefg123456",
                   "gitlab_url"=>"http://192.168.1.1",
                   "gitlab_mirror_user"=>"gitmirror",
                   "system_mirror_user"=>"gitmirror",
                   "system_mirror_group"=>"gitmirror",
                   "system_user_home_dir"=>"/home/gitmirror",
                   "mirror_repo"=>"https://github.com/samrocketman/gitlab-mirrors.git",
                   "mirror_repo_dir_name"=>"gitlab-mirrors",
                   "repositories_dir_name"=>"repositories",
                   "gitlab_namespace"=>"gitlab-mirrors",
                   "generate_public_mirrors"=>"true",
                   "ensure_mirror_update_job"=>"present",
                   "prune_mirrors"=>"true",
                   "force_update"=>"true",
                   #"require"=>"Class[gitlab_mirrors::install_dependencies, gitlab_mirrors::install]"
                  })
  end
  it do
    is_expected.to contain_class('gitlab_mirrors::mirror_list').
             with({ "mirror_list_repo"          => 'https://github.com/logicminds/mirror_list.git',
                    "mirror_list_repo_path"     =>'/home/gitmirror/mirror_list',
                   "ensure_mirror_sync_job"=>"present",
                   "system_mirror_user"=>"gitmirror",
                   "system_mirror_group"=>"gitmirror",
                   "gitlab_mirrors_repo_dir_path"=>"/home/gitmirror/gitlab-mirrors",
                   "mirrors_list_yaml_file"=>"mirror_list.yaml",
                   "ensure_mirror_list_repo_cron_job"=>"present",
                   "system_user_home_dir"=>"/home/gitmirror",
                   #"require"=>"Class[Gitlab_mirrors::config]"
                  })
  end
end
