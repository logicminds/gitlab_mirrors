# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
class{'gitlab_mirrors':
  mirror_list_repo         => 'https://github.com/logicminds/mirror_list.git',
  mirror_list_repo_path    => '/home/gitmirror/mirror_list',
  gitlab_mirror_user_token  => 'xyXdTA6x5J3hF_TSgoSj',
  gitlab_url                => 'https://centos6',
  gitlab_mirror_user        => 'user123',
  system_mirror_user        => 'gitmirror',
  system_mirror_group       => 'gitmirror',
  mirror_repo               => 'https://github.com/samrocketman/gitlab-mirrors.git',
  repositories_dir_name     => 'repositories',
  gitlab_namespace          => 'my_namespace',
  generate_public_mirrors   => true,
  ensure_mirror_update_job  => present,
  prune_mirrors             => true,
  force_update              => true,
  ensure_mirror_sync_job    => present,
  mirrors_list_yaml_file    => 'mirror_list.yaml',
  ensure_mirror_list_repo_cron_job => present,
  configure_mirror_list_feature => true,
  install_dependencies      => 'true'
}
