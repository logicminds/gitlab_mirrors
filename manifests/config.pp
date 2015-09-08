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
  $ssh_rsa_public_key        = undef ,
  $ssh_rsa_private_key       = undef,
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
  # this is here just to satisfy dependencies and ordering
    file{$system_user_home_dir: }
  }
  file{"${system_user_home_dir}/.ssh":
    ensure => directory,
    require => File[$system_user_home_dir]
  }

# ssh-keygen for gitmirror user
# you will then need to add this key to the gitlab account
  if $ssh_rsa_private_key == undef {
    exec{ 'generate_key':
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      user    => $system_mirror_user,
      command => 'cat /dev/zero | ssh-keygen -t rsa -b 2048 -q -N ""',
      creates => "${system_user_home_dir}/.ssh/id_rsa.pub",
      require => File[$system_user_home_dir]
    }
  }
  # if you want to use pregenerated keys, then we can just
  # reuse them here
  else {
    file{"${system_user_home_dir}/.ssh":
      ensure => directory,
    }
    file{"${system_user_home_dir}/.ssh/id_rsa":
      ensure => file,
      content => $ssh_rsa_private_key,
      mode => 600,
      require => File["${system_user_home_dir}/.ssh"]
    }
    file{"${system_user_home_dir}/.ssh/id_rsa.pub":
      ensure => file,
      content => $ssh_rsa_public_key,
      mode => 644,
      require => File["${system_user_home_dir}/.ssh"]
    }
  }
  file{ "${system_user_home_dir}/.ssh/config":
    ensure  => file,
    content => "Host ${gitlab_url}\n\tUser git",
    require => File["${system_user_home_dir}/.ssh"]
  }

  file{$mirrored_repo_dir:
    ensure => 'directory',
    require => File[$system_user_home_dir]
  }

  file{ "${system_user_home_dir}/private_token":
    ensure => file,
    content => $gitlab_mirror_user_token,
    require => File[$system_user_home_dir],
    mode => '0640'
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
    environment => 'PATH=$PATH:/usr/local/bin:/usr/bin:/bin',
    command => "source /etc/profile ; ${repo_dir}/git-mirrors.sh 2>&1 > /dev/null",
    ensure => $ensure_mirror_update_job,
    hour => '*',
    minute => '0',
    user => $system_mirror_user,
    require => Exec['git_mirrors']
  }
}