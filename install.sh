apt-get install ant zip unzip default-jdk default-jre curl
cd /opt
curl -L -o adito-0.9.1-bin.tar.gz http://sourceforge.net/projects/openvpn-als/files/adito/adito-0.9.1/adito-0.9.1-bin.tar.gz/download
tar -zxvf adito-0.9.1-bin.tar.gz
cd adito-0.9.1
install_dir=$(pwd)


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
a2ensite adito
service apache2 restart

ant install && \
a2dissite adito
service apache2 stop && \
ant create-wrapper-conf && \
sed -i.bak -e "s|^wrapper.working.dir=.*|wrapper.working.dir=$install_dir|" conf/wrapper.conf && \
sed -i.bak -e "s|^wrapper.java.library.path.1=install/platforms/linux/x86$|wrapper.java.library.path.1=install/platforms/linux/x86-64|" conf/wrapper.conf && \
ant install-service && \
/etc/init.d/adito start

