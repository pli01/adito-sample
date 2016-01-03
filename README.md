# adito-sample

As i run instances in the cloud, where only port 80 & 443 are open, i wrote
thsi script wich install/configure/run adito on port 80/443

Step:
 - download & extract adito in /opt
 - configure apache reverse proxy port 80 to 28080
 - run adito first config on default port  28080
 - Connect on your http://publicIP and configure adito
 - follow wizard pages (ssl,admin account
 - when done (exit install throuch installer wizard)
 - apache will disable, and let adito run on 80/443 port
 - finally connect on your https://publicIP and use adito

Tips to allow adito-agent on MacOs Client
 - java preferences: allow self certificate (url https://publicIP)
 - active Debug in Profile Menu/Default/Configure/Adito Agent/Debug
 - create ssh tunnel over https: Create Tunnel/Source Interface/Port (localhost:2323) Destination Host/Port (privateip/22)

Install:
 ’’’
wget -q -O - https://raw.githubusercontent.com/pli01/adito-sample/master/install.sh  |bash -x
’’’

Docs:
 - https://wiki.amahi.org/index.php/Adito_notes
 - http://www.anonyproz.com/stealth-ssh.pdf
 - http://lars.werner.no/?page_id=153
