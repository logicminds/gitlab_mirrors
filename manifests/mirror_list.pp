class gitlab_mirrors::mirror_list(
  $mirror_list_repo = undef,
  $mirror_list_repo_path,
  $mirror_list_file_source = "puppet:///modules/gitlab_mirrors/mirror_list.yaml"
) {
# if we are lazy and just want to maintain a file in a puppet module we can just use the source location
  if $mirror_list_repo == undef and $mirror_list_file_source {
    $ensure_cron_job = absent

    file{$mirror_list_repo_path:
      ensure => directory
    }

    file{"${mirror_list_repo_path}/mirror_list.yaml":
      ensure => file,
      source => $mirror_list_file_source,
      require => File[$mirror_list_repo_path],
      before => Cron['sync mirror list repo']
    }
  }
  else{
  # it is expected that you will be maintaining a separate repo that contains the mirror_list yaml file
  # since we want this repo to always have the latest list we create a cron job for it
    git{$mirror_list_repo_path:
      ensure => present,
      branch => 'master',
      latest => true,
      origin => $mirror_list_repo,
      before => Cron['sync mirror list repo']
    }
    $ensure_cron_job = present
  }
  cron{'sync mirror list repo':
    ensure => $ensure_cron_job,
    command => "cd ${mirror_list_repo_path} && git pull 2>&1 > /dev/null",
    minute => '05',
  }

}