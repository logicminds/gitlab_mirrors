class gitlab_mirrors::install{
  package{'gitlab3':
    ensure => '0.5.4',
    provider => 'pip',
  }

  #echo -n | openssl s_client -connect HOST:PORTNUMBER | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/$SERVERNAME.cert

}