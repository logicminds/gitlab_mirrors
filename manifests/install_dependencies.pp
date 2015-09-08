class gitlab_mirrors::install_dependencies(
  $install_dependencies = 'false'
){
# this class requires pip and python to be installed
  if $::id == 'root' and $install_dependencies {
    if $::osfamily == 'RedHat' {
      # install epel so we can install python-pip
      # if using docker, you will need to have the lsb package installed
      # or do export FACTER_operatingsystemmajrelease=7 && puppet apply
      case $::operatingsystemmajrelease {
        '6': {
          package{'epel-release':
            ensure => 'installed',
            source => 'https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm',
            provider => 'rpm',
            before   => Package['git', 'python-pip']
          }
          package{'python-pip': ensure => present}

        }
        default: {
          package{ 'epel-release':
            ensure => 'installed',
            source => 'https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm',
            provider => 'rpm',
            before   => Package['git', 'python-pip']
          }
          package{'python-pip': ensure => present}
        }
      }
    }
    else {
      exec{'easy_install pip':
        command => 'easy_install pip',
        path => ['/bin', '/usr/bin']
      }
    }
    package{'git': ensure => present}
  }
}