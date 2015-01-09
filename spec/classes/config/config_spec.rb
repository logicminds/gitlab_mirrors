require 'spec_helper'
require 'shared_contexts'

describe 'gitlab_mirrors::config' do
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
      :gitlab_mirror_user_token => 'abcdefg123456',
      :gitlab_url => "http://192.168.1.1",
      :gitlab_mirror_user => "gitmirror",
      :system_mirror_user => "gitmirror",
      :system_user_home_dir => "/home/gitmirror",
      :mirror_repo => "https://github.com/samrocketman/gitlab-mirrors.git",
      :mirror_repo_dir_name => "gitlab-mirrors",
      :repositories_dir_name => "repositories",
      :gitlab_namespace => "gitlab-mirrors",
      :generate_public_mirrors => true,
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it { should contain_git('/home/gitmirror/gitlab-mirrors').with_ensure('present').
                with_origin('https://github.com/samrocketman/gitlab-mirrors.git').
                with_branch('master')
  }
  it {should contain_exec('generate_key').with_user('gitmirror').with_creates('/home/gitmirror/.ssh/id_rsa.pub') }
  it { should contain_file('/home/gitmirror/.ssh/config').with_ensure('file').
                with_content("Host http://192.168.1.1\n\tUser git")}
  it { should contain_file('/home/gitmirror/repositories').with_ensure('directory')}
  it { should contain_file('/home/gitmirror/private_token').with_ensure('file').with_content('abcdefg123456')}
  it { should contain_file('/home/gitmirror/gitlab-mirrors/config.sh').with_ensure('file')}

  describe 'enable cron job' do
    let(:params) do
      {
        :gitlab_mirror_user_token => 'abcdefg123456',
        :gitlab_url => "http://192.168.1.1",
        :gitlab_mirror_user => "gitmirror",
        :system_mirror_user => "gitmirror",
        :system_user_home_dir => "/home/gitmirror",
        :mirror_repo => "https://github.com/samrocketman/gitlab-mirrors.git",
        :mirror_repo_dir_name => "gitlab-mirrors",
        :repositories_dir_name => "repositories",
        :gitlab_namespace => "gitlab-mirrors",
        :generate_public_mirrors => true,
        :ensure_mirror_update_job => 'present'
      }
    end
    it { should contain_cron('gitlab mirrors update job').
                  with_command('/home/gitmirror/gitlab-mirrors/git-mirrors.sh 2>&1 > /dev/null').
                  with_ensure('present').with_user('gitmirror')
    }
  end

  describe 'disable cron job' do
    let(:params) do
      {
        :gitlab_mirror_user_token => 'abcdefg123456',
        :gitlab_url => "http://192.168.1.1",
        :gitlab_mirror_user => "gitmirror",
        :system_mirror_user => "gitmirror",
        :system_user_home_dir => "/home/gitmirror",
        :mirror_repo => "https://github.com/samrocketman/gitlab-mirrors.git",
        :mirror_repo_dir_name => "gitlab-mirrors",
        :repositories_dir_name => "repositories",
        :gitlab_namespace => "gitlab-mirrors",
        :generate_public_mirrors => true,
        :ensure_mirror_update_job => 'absent'
      }
    end
    it { should contain_cron('gitlab mirrors update job').with_ensure('absent') }
  end
end
