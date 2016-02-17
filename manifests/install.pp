class gitlab_mirrors::install(
  $install_dependencies = false
){
  if $install_dependencies {
    package{ 'gitlab3':
      ensure   => '0.5.4',
      provider => 'pip',
    }
    if $::osfamily == 'RedHat' {
    # https://tickets.puppetlabs.com/browse/PUP-3829
      file { '/usr/bin/pip-python':
        ensure => 'link',
        target => '/usr/bin/pip',
        before => Package['gitlab3']
      }
    }
  }
}