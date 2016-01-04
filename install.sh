#!/bin/bash
# prepare redirect 80 to 28080
# initial adito config
# then disable apache 80
# fix install_dir and platform
# then run adito on 80/443

set -x
test -f /opt/adito-0.9.1/conf/wrapper.conf && exit 0
test -d /opt/adito-0.9.1 && exit 0

DEBIAN_FRONTEND=noninteractive apt-get -y -q install ant zip unzip default-jdk default-jre curl apache2

if [ ! -f /opt/adito-0.9.1-bin.tar.gz ] ; then
 curl -L -o /opt/adito-0.9.1-bin.tar.gz http://sourceforge.net/projects/openvpn-als/files/adito/adito-0.9.1/adito-0.9.1-bin.tar.gz/download
 ( cd /opt && tar -zxvf /opt/adito-0.9.1-bin.tar.gz )
fi

test -d /opt/adito-0.9.1 || exit 1

# redirect 80 to 28080 during initial config
cat <<EOF > /etc/apache2/sites-available/adito.conf
Listen 80
<VirtualHost *:80>
  ProxyVia On
  ProxyRequests Off
  ProxyPass / http://localhost:28080/
  ProxyPassReverse / http://localhost:28080/
  ProxyPreserveHost on
  <Proxy *>
    Options FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    allow from all
  </Proxy>
</VirtualHost>
EOF

cat <<EOF > /etc/apache2/sites-available/adito-ssl.conf
<IfModule mod_ssl.c>
<VirtualHost *:443>
  SSLEngine on
  SSLCertificateFile	/etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
  ProxyVia On
  SSLProxyEngine On
  ProxyRequests Off
  ProxyPreserveHost Off
  ProxyPass / http://localhost:7443/
  ProxyPassReverse / http://localhost:7443/
  <Proxy *>
    Options FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    allow from all
  </Proxy>
</VirtualHost>
</IfModule>
EOF

sed -i.old  -e 's/^Listen\(.*\)/#Listen\1/' /etc/apache2/ports.conf

a2enmod proxy proxy_http headers deflate
a2dismod ssl
a2dissite 000-default default-ssl adito-ssl
a2ensite adito
update-rc.d apache2 enable
service apache2 restart

cd /opt/adito-0.9.1
install_dir=$(pwd)
ant install && \
a2dissite adito && \
service apache2 stop && \
update-rc.d apache2 disable && \
ant create-wrapper-conf && \
sed -i.bak -e "s|^wrapper.working.dir=.*|wrapper.working.dir=$install_dir|" conf/wrapper.conf && \
sed -i.bak -e "s|^wrapper.java.library.path.1=install/platforms/linux/x86$|wrapper.java.library.path.1=install/platforms/linux/x86-64|" conf/wrapper.conf && \
sed -i.bak -e "s|^wrapper.java.additional.2=.*|wrapper.java.additional.2=-Dfile.encoding=UTF-8|" conf/wrapper.conf && \
ant install-service && \
/etc/init.d/adito start

# jobs done
#sed -i.bak -e "s|^webServer.protocol=.*|webServer.protocol=http|" conf/webserver.properties && \
#sed -i.bak -e "s|^webServer.port=.*|webServer.port=7443|" conf/webserver.properties && \
#a2ensite adito-ssl && \
