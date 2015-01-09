require 'spec_helper'
require 'shared_contexts'

describe 'gitlab_mirrors::mirror_list' do
  # by default the hiera integration uses hirea data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  include_context :hiera


  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end
  # below is a list of the resource parameters that you can override
  # by default all non-required parameters are commented out
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:mirror_list_repo => undef,
      :mirror_list_repo_path => '/home/gitmirror/mirror_list',
      #:mirror_list_file_source => "puppet:///modules/gitlab_mirrors/mirror_list.yaml",
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  describe 'mirror list repo is defined' do
    let(:params) do
      {
        :mirror_list_repo => 'https://github.com/logicminds/gitlab_mirrors.git',
        :mirror_list_repo_path => '/home/gitmirror/mirror_list',
        #:mirror_list_file_source => "puppet:///modules/gitlab_mirrors/mirror_list.yaml",
        :ensure_mirror_sync_job    => 'present',
        :system_mirror_user        => 'gitmirror',
        :gitlab_mirrors_repo_dir_path => '/home/gitmirror/gitlab-mirrors',
        :system_user_home_dir => '/home/gitmirror'
      }
    end
    it { should contain_cron('sync mirror list repo').with_ensure('present').
                  with_command('cd /home/gitmirror/mirror_list && git pull 2>&1 > /dev/null')}
    it { should contain_git('/home/gitmirror/mirror_list').with_ensure('present').
                  with_origin('https://github.com/logicminds/gitlab_mirrors.git').
                  with_branch('master')
    }
    it { should_not contain_file('/home/gitmirror/mirror_list')}
    it { should_not contain_file('/home/gitmirror/mirror_list/mirror_list.yaml')}
    it { should contain_cron('gitlab mirrors sync job').
                  with_command('/home/gitmirror/sync_mirrors.rb /home/gitmirror/gitlab-mirrors '+
                                 '/home/gitmirror/mirror_list/mirror_list.yaml 2>&1 > /dev/null').
                  with_ensure('present').with_user('gitmirror')
    }
    it { should contain_file('/home/gitmirror/sync_mirrors.rb').with_ensure('file').
                  with_source('puppet:///modules/gitlab_mirrors/sync_mirrors.rb')

    }
  end
end
