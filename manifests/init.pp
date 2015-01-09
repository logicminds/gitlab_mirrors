# == Class: gitlab_mirrors
#
# Full description of class gitlab_mirrors here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'gitlab_mirrors':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class gitlab_mirrors(
  $gitlab_mirror_user_token,
  $gitlab_url,
  $mirror_list_repo,
  $mirror_list_repo_path,
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
  $ensure_mirror_sync_job    = present,
  $mirrors_list_yaml_file    = 'mirror_list.yaml',
  $ensure_mirror_list_repo_cron_job = present,
  $configure_mirror_list_feature = true,
) {

  include gitlab_mirrors::install
  class{'gitlab_mirrors::config':
    gitlab_mirror_user_token  => $gitlab_mirror_user_token,
    gitlab_url                => $gitlab_url,
    gitlab_mirror_user        => $gitlab_mirror_user,
    system_mirror_user        => $system_mirror_user,
    system_mirror_group       => $system_mirror_group,
    system_user_home_dir      => $system_user_home_dir,
    mirror_repo               => $mirror_repo,
    mirror_repo_dir_name      => $mirror_repo_dir_name,
    repositories_dir_name     => $repositories_dir_name,
    gitlab_namespace          => $gitlab_namespace,
    generate_public_mirrors   => $generate_public_mirrors,
    ensure_mirror_update_job  => $ensure_mirror_update_job,
    prune_mirrors             => $prune_mirrors,
    force_update              => $force_update,
    require                   => Class['gitlab_mirrors::install']
  }
  if $configure_mirror_list_feature == true {
    class{'gitlab_mirrors::mirror_list':
      mirror_list_repo          => $mirror_list_repo,
      mirror_list_repo_path     =>$mirror_list_repo_path,
      ensure_mirror_sync_job    => $ensure_mirror_sync_job,
      system_mirror_user        => $system_mirror_user,
      system_mirror_group       => $system_mirror_group,
      gitlab_mirrors_repo_dir_path => "${system_user_home_dir}/${mirror_repo_dir_name}",
      mirrors_list_yaml_file    => $mirrors_list_yaml_file,
      ensure_mirror_list_repo_cron_job => $ensure_mirror_list_repo_cron_job,
      system_user_home_dir      => $system_user_home_dir,
      require                   => Class['gitlab_mirrors::config']
    }
  }

}
