class gitlab_mirrors::config(
  $gitlab_mirror_user_token,
  $gitlab_url                = 'http://192.168.1.1',
  $gitlab_mirror_user        = 'gitmirror',
  $system_mirror_user        = 'gitmirror',
  $base_home_dir             = '/home',
  $mirror_repo               = 'https://github.com/samrocketman/gitlab-mirrors.git',
  $mirror_repo_dir_name      = 'gitlab-mirrors',
  $repositories_dir_name     = 'repositories',
  $gitlab_namespace          = 'gitlab-mirrors',
  $generate_public_mirrors   = true,
  $ensure_mirror_sync_job    = absent,
  $ensure_mirror_update_job  = present,
){
  $home_dir = "${base_home_dir}/${system_mirror_user}"
  $repo_dir = "${home_dir}/${mirror_repo_dir_name}"
  $mirrored_repo_dir = "${home_dir}/${repositories_dir_name}"

  user{$system_mirror_user:
    ensure => present,
  }

  # ssh-keygen for gitmirror user
  exec{'generate_key':
    path => ['/bin', '/usr/bin', '/usr/sbin'],
    user => $system_mirror_user,
    command => 'cat /dev/zero | ssh-keygen -t rsa -b 2048 -q -N ""',
    creates => "${home_dir}/.ssh/id_rsa.pub",
  }

  file{ "${home_dir}/.ssh/config":
    ensure  => file,
    content => "Host ${gitlab_url}\n\tUser git",
    require => Exec['generate_key']
  }

  file{$mirrored_repo_dir:
    ensure => 'directory',

  }
  file{ "${home_dir}/private_token":
    ensure => file,
    content => $gitlab_mirror_user_token
  }

  file{"${repo_dir}/config.sh":
    ensure => file,
    content => template('gitlab_mirrors/config.sh'),
    require => Git[$repo_dir]
  }

  git{$repo_dir:
    ensure => present,
    branch => 'master',
    latest => true,
    origin => $mirror_repo
  }
  cron{'gitlab mirrors sync job':
    command => "ruby ${repo_dir}/sync_mirrors.rb 2>&1 > /dev/null",
    ensure => $ensure_mirror_sync_job,
    hour => '*',
    minute => '10'
  }

  cron{'gitlab mirrors update job':
    command => "ruby ${repo_dir}/git-mirror.sh 2>&1 > /dev/null",
    ensure => $ensure_mirror_update_job,
    hour => '*',
    minute => '0'
  }


}