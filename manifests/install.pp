class gitlab_mirrors::install{
  # this class requires pip and python to be installed
  package{'gitlab3':
    ensure => '0.5.4',
    provider => 'pip',
  }

}