class gitlab_mirrors::config(
  $gitlab_mirror_user_token,
  $gitlab_url,               # 'http://192.168.1.1',
  $gitlab_mirror_user        = 'gitmirror',
  $system_mirror_user        = 'gitmirror',
  $system_mirror_group       = 'gitmirror',
  $system_user_home_dir      = '/home/gitmirror',
  $mirror_repo               = 'https://github.com/samrocketman/gitlab-mirrors.git',
  $mirror_repo_dir_name      = 'gitlab-mirrors',
  $repositories_dir_name     = 'repositories',
  $gitlab_namespace          = 'gitlab-mirrors',
  $generate_public_mirrors   = true,
  $ensure_mirror_update_job  = present,
  $prune_mirrors             = true,
  $force_update              = true,
  $gitlab_mirrors_branch     = 'master',
){
  include gitlab_mirrors::install

  $repo_dir = "${system_user_home_dir}/${mirror_repo_dir_name}"
  $mirrored_repo_dir = "${system_user_home_dir}/${repositories_dir_name}"

  File{
    owner => $system_mirror_user,
    group => $system_mirror_group
  }
  # in case you happen to be running this as a non-root user, the following code will work
  if $::id == 'root' {
    user{ $system_mirror_user:
      ensure => present,
    }
    file{$system_user_home_dir:
      ensure => 'directory',
      require => User[$system_mirror_user]
    }
  } else {

    file{$system_user_home_dir: }
  }


# ssh-keygen for gitmirror user
  exec{'generate_key':
    path => ['/bin', '/usr/bin', '/usr/sbin'],
    user => $system_mirror_user,
    command => 'cat /dev/zero | ssh-keygen -t rsa -b 2048 -q -N ""',
    creates => "${system_user_home_dir}/.ssh/id_rsa.pub",
    require => File[$system_user_home_dir]
  }

  file{ "${system_user_home_dir}/.ssh/config":
    ensure  => file,
    content => "Host ${gitlab_url}\n\tUser git",
    require => Exec['generate_key']
  }

  file{$mirrored_repo_dir:
    ensure => 'directory',
    require => File[$system_user_home_dir]
  }

  file{ "${system_user_home_dir}/private_token":
    ensure => file,
    content => $gitlab_mirror_user_token,
    require => File[$system_user_home_dir],
    mode => 640

  }

  file{"${repo_dir}/config.sh":
    ensure => file,
    content => template('gitlab_mirrors/config.sh.erb'),
    require => Exec['git_mirrors']
  }
  exec{'git_mirrors':
    path => ['/bin', '/usr/bin'],
    cwd => $system_user_home_dir,
    command => "git clone -b $gitlab_mirrors_branch $mirror_repo $repo_dir",
    require => File[$system_user_home_dir],
    notify => Exec["chown ${repo_dir}"],
    user   => $system_mirror_user,
    logoutput => true,
    creates => "${repo_dir}/.git"

  }

  exec{"chown ${repo_dir}":
    command => "chown -R ${system_mirror_user}:${system_mirror_group} ${repo_dir}",
    path => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  cron{'gitlab mirrors update job':
    command => "${repo_dir}/git-mirrors.sh 2>&1 > /dev/null",
    ensure => $ensure_mirror_update_job,
    hour => '*',
    minute => '0',
    user => $system_mirror_user,
    require => Exec['git_mirrors']
  }
}