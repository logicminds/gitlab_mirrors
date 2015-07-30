 # may need to install certifi, urllib3
  # may need to add self signed ca to certifi
  #cat /etc/ssl/certs/pe-master.localdomain.crt >> /usr/lib/python2.6/site-packages/certifi/cacert.pem
  #echo -n | openssl s_client -connect HOST:PORTNUMBER | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/$SERVERNAME.cert
  # certifi-2015.04.28.dist-info
  #http://stackoverflow.com/questions/22509271/import-self-signed-certificate-in-redhat
  #openssl s_client -connect 192.168.1.33:443 <<<'' |  openssl x509 -out /etc/pki/tls/certs/gitlab.localdomain.crt
  #ln -sv /etc/pki/tls/certs/gitlab.localdomain.crt $(openssl x509 -in /etc/pki/tls/certs/gitlab.localdomain.crt -noout -hash).0

  #yum install centos-release-SCL