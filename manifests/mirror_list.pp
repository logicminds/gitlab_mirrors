class gitlab_mirrors::mirror_list(
  $mirror_list_repo,
  $mirror_list_repo_path,
  $system_user_home_dir,
  $gitlab_mirrors_repo_dir_path,
  $ensure_mirror_sync_job    = present,
  $system_mirror_user        = 'gitmirror',
  $system_mirror_group       = 'gitmirror',
  $mirrors_list_yaml_file    = 'mirror_list.yaml',
  $ensure_mirror_list_repo_cron_job = present,
  $mirror_list_branch = 'master'
) {

  $mirror_list = "${mirror_list_repo_path}/${mirrors_list_yaml_file}"

  File{
    owner => $system_mirror_user,
    group => $system_mirror_group
  }

# it is expected that you will be maintaining a separate repo that contains the mirror_list yaml file
# since we want this repo to always have the latest list we create a cron job for it
  exec{'git_mirror_list':
    path      => ['/bin', '/usr/bin'],
    cwd       => $system_user_home_dir,
    command   => "git clone -b ${mirror_list_branch} ${mirror_list_repo} ${mirror_list_repo_path}",
    before    => Cron['sync mirror list repo'],
    notify    => Exec['chown_mirror_list'],
    creates   => "${mirror_list_repo_path}/.git",
    logoutput => true,
    user      => $system_mirror_user
  }

  exec{'chown_mirror_list':
    command     => "chown -R ${system_mirror_user}:${system_mirror_group} ${mirror_list_repo_path}",
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
  }
  cron{'sync mirror list repo':
    ensure      => $ensure_mirror_list_repo_cron_job,
    environment => 'PATH=$PATH:/usr/local/bin:/usr/bin:/bin',
    command     => "source /etc/profile ; cd ${mirror_list_repo_path} ; git pull 2>&1 > /dev/null",
    minute      => '05',
    user        => $system_mirror_user,
  }

  file{"${system_user_home_dir}/sync_mirrors.rb":
    ensure  => file,
    source  => 'puppet:///modules/gitlab_mirrors/sync_mirrors.rb',
    require => Exec['git_mirror_list'],
    mode    => '0750'
  }

  cron{'gitlab mirrors sync job':
    ensure  => $ensure_mirror_sync_job,
    command => "source /etc/profile ; ${system_user_home_dir}/sync_mirrors.rb ${gitlab_mirrors_repo_dir_path} ${mirror_list} 2>&1 > /dev/null",
    hour    => '*',
    minute  => '10',
    user    => $system_mirror_user,
    require => File["${system_user_home_dir}/sync_mirrors.rb"]
  }

}
