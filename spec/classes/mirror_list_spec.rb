require 'spec_helper'
require 'shared_contexts'

describe 'gitlab_mirrors::mirror_list' do
  # by default the hiera integration uses hirea data from the shared_contexts.rb file
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

    it do
      is_expected.to contain_exec('git_mirror_list').
                         with({"command"=>'git clone -b master https://github.com/logicminds/gitlab_mirrors.git /home/gitmirror/mirror_list',
                               "user"=> 'gitmirror',
                               "before"=>"Cron[sync mirror list repo]",
                               "notify"=>"Exec[chown_mirror_list]",
                               "creates" => '/home/gitmirror/mirror_list/.git'
                              })
    end
    it do
      is_expected.to contain_exec('chown_mirror_list').
                         with({"command"=>"chown -R gitmirror:gitmirror /home/gitmirror/mirror_list",
                               "refreshonly"=>"true"})
    end
    it do
      is_expected.to contain_cron('sync mirror list repo').
                         with({"ensure"=>"present",
                               "command"=>"source /etc/profile ; cd /home/gitmirror/mirror_list ; git pull 2>&1 > /dev/null",
                               "minute"=>"05"})
    end
    it do
      is_expected.to contain_file('/home/gitmirror/sync_mirrors.rb').
                         with({"ensure"=>"file",
                               "source"=>"puppet:///modules/gitlab_mirrors/sync_mirrors.rb",
                               "require"=>"Exec[git_mirror_list]",
                               "mode"=>"750"})
    end
    it do
      is_expected.to contain_cron('gitlab mirrors sync job').
                         with({"command"=>"source /etc/profile ; /home/gitmirror/sync_mirrors.rb /home/gitmirror/gitlab-mirrors /home/gitmirror/mirror_list/mirror_list.yaml 2>&1 > /dev/null",
                               "ensure"=>"present",
                               "hour"=>"*",
                               "minute"=>"10",
                               "user"=>"gitmirror",
                               "require"=>"File[/home/gitmirror/sync_mirrors.rb]"})
    end
  end
end
