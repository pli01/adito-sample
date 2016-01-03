#!/bin/bash
# prepare redirect 80 to 28080
# initial adito config
# then disable apache 80
# fix install_dir and platform
# then run adito on 80/443

test -f /opt/adito-0.9.1/conf/wrapper.conf && exit 0
test -d /opt/adito-0.9.1 && exit 0

apt-get install ant zip unzip default-jdk default-jre curl apache2

cd /opt

if [ ! -f adito-0.9.1-bin.tar.gz ] ; then
 curl -L -o adito-0.9.1-bin.tar.gz http://sourceforge.net/projects/openvpn-als/files/adito/adito-0.9.1/adito-0.9.1-bin.tar.gz/download
 tar -zxvf adito-0.9.1-bin.tar.gz
fi

test -d adito-0.9.1 || exit 1

# redirect 80 to 28080 during initial config
cat <<EOF > /etc/apache2/sites-available/adito.conf
<VirtualHost *:80>
  LoadModule  proxy_module         /usr/lib/apache2/modules/mod_proxy.so
  LoadModule  proxy_http_module    /usr/lib/apache2/modules/mod_proxy_http.so
  LoadModule  headers_module       /usr/lib/apache2/modules/mod_headers.so
  LoadModule  deflate_module       /usr/lib/apache2/modules/mod_deflate.so
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

a2dissite 000-default
a2dissite default-ssl
a2ensite adito
update-rc.d apache2 enable
service apache2 restart

cd adito-0.9.1
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
