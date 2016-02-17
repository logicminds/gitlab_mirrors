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
  mirror_list_repo                 => 'git@github.com:logicminds/mirror_list.git',
  mirror_list_repo_path            => '/home/gitmirror/mirror_list',
  gitlab_mirror_user_token         => '123i82idjskj2332jdiot',
  gitlab_url                       => 'https://gitlab.com',
  gitlab_mirror_user               => 'cosman2001',
  system_mirror_user               => 'gitmirror',
  system_mirror_group              => 'gitmirror',
  mirror_repo                      => 'https://github.com/samrocketman/gitlab-mirrors',
  repositories_dir_name            => 'repositories',
  gitlab_namespace                 => 'singlestone',
  generate_public_mirrors          => true,
  ensure_mirror_update_job         => present,
  prune_mirrors                    => true,
  force_update                     => true,
  ensure_mirror_sync_job           => present,
  mirrors_list_yaml_file           => 'mirror_list.yaml',
  ensure_mirror_list_repo_cron_job => present,
  configure_mirror_list_feature    => true,
  install_dependencies             => true,
  mirror_list_branch               => 'master',
  gitlab_mirrors_branch            => 'development',
}
