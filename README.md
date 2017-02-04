# docker-server-stack

## Configure server

### Create sudo user and disable root
Create sudo user and test it
```
root$ adduser <user>
root$ usermod -aG sudo <user>
root$ su - <user>
<user>$ sudo ls -la /root
```
Logout and login in with new user
```
$ ssh <user>@<ip>
```
Disable root and try to login with root. It shouldn't work anymore
```
$ sudo passwd -l root
$ ssh root@<ip>
```

### Add localizations to UTF-8
You need to add locales to every user you have created
```
$ sudo locale-gen en_US.UTF-8
$ echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
$ echo "export LANG=en_US.UTF-8" >> ~/.bashrc
$ echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc
$ source ~/.bashrc
```

###  Install NTP and configure timezone to Helsinki
```
$ sudo apt install ntp
$ echo "Europe/Helsinki" | sudo tee /etc/timezone
$ sudo dpkg-reconfigure -f noninteractive tzdata
```
### Change ssh default port to 2222
Backup sshd_config file and edit sshd_config
```
$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
$ sudoedit /etc/ssh/sshd_config
```
Change ssh default port 22 to 2222. sshd_config file should look like this
```
# What ports, IPs and protocols we listen for
# Port 22
Port 2222
```
Restart ssh daemon and login in with new 2222 port
```
$ sudo service sshd restart
$ ssh <user>@<ip> -p 2222
```

### Configure firewall and enable new rules
Allow new ssh 2222 port and http/https tcp connection. Allow all outgoing and deny incomings except 2222, http and https. Enable new rules.
```
$ sudo ufw allow 2222
$ sudo ufw allow http/tcp
$ sudo ufw allow https/tcp
$ sudo ufw default allow outgoing
$ sudo ufw default deny incoming
$ sudo ufw enable
```

### Install and configure fail2ban
Install fail2ban. Backup jail.conf and configure fail2ban.
```
$ sudo apt install fail2ban
$ sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.backup
$ sudoedit /etc/fail2ban/jail.conf
```
jail.conf file should look like this.
```
[sshd]

# port    = ssh
# logpath = %(sshd_log)s

enabled  = true
port     = 2222
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 6
bantime  = 6000
```
Restart jail2ban service and check your sshd rule is enabled
```
$ sudo service fail2ban restart
$ sudo fail2ban-client status

Status
|- Number of jail:      1
`- Jail list:   sshd

```

### Install softwares what you need or are nice to have
```
$ sudo apt install tree pwgen
$ sudo apt install git mysql-client
```

## Install docker-engine and docker-compose

### Install docker-engine
Source doc: https://docs.docker.com/engine/installation/linux/ubuntu/

Add docker to package list etc.
```
$ sudo apt-get install curl \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
$ sudo apt-get install apt-transport-https \
                       ca-certificates
$ curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -
$ apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -cs) \
       main"
```
Update package lists and install docker-engine
```
$ sudo apt-get update
$ sudo apt-get -y install docker-engine
```
Test docker-engine, delete container and image after that
```
$ sudo docker run hello-world
$ sudo docker rm -v $(sudo docker ps -a -q)
$ sudo docker rmi $(sudo docker images -q)
```

### Install docker-compose
Source doc: https://docs.docker.com/compose/install/

Install docker-compose, add excecute rights and test docker-compose command
```
$ sudo sh -c "curl -L https://github.com/docker/compose/releases/download/1.10.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
```

### Reboot server
This is good point to restart server
```
$ sudo reboot
```

## Deploy docker-server-stack

### Clone docker-server-stack repository
Create /docker folder and clone repository
```
$ sudo mkdir /docker
$ cd /docker
$ sudo git clone https://github.com/Soivi/docker-server-stack

```
Create needed folders
```
$ sudo mkdir www data log
```


## Importing & setting up an existing mysql database to a docker container volume:

$ mkdir -p ~/backup  
$ mysqldump -u user -p <database name> | gzip -9 > ~/backup/$(date +"%Y%m%d")_wordpress.sql.gz  
$ mysqldump -u <user> -p <database name> > ~/backup/$(date +"%Y%m%d")_wordpress.sql.gz

$ tar -zcvf ~/backup/$(date +"%Y%m%d")_wordpress-dir.tar.gz /home/user/public_html/wordpress  

sudo apt install mysql-client  
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockerserverstack_mysql-wp-soivi_1  
172.21.0.3  
mysql <database> -u <user> -p -h <ip> < ~/backup/20170109_wordpress.sql  


sudo chown -R 33:33 wordpress/  
sudo chmod -R 755 wp-content/  
