apt-get install ant zip unzip default-jdk default-jre curl
cd /opt
curl -L -o adito-0.9.1-bin.tar.gz http://sourceforge.net/projects/openvpn-als/files/adito/adito-0.9.1/adito-0.9.1-bin.tar.gz/download
tar -zxvf adito-0.9.1-bin.tar.gz
cd adito-0.9.1
install_dir=$(pwd)
ant install && \
ant create-wrapper-conf && \
sed -i.bak -e "s|^wrapper.working.dir=.*|wrapper.working.dir=$install_dir|" conf/wrapper.conf && \
sed -i.bak -e "s|^wrapper.java.library.path.1=install/platforms/linux/x86$|wrapper.java.library.path.1=install/platforms/linux/x86-64|" conf/wrapper.conf && \
ant install-service && \
/etc/init.d/adito start

