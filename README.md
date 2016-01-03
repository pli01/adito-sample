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
 - allow self certificat (https://publicIP)
 - active Debug mon in Profile Menu/Tunnel

