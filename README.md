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

Update APT package list and update server
```
$ sudo apt update && sudo apt dist-upgrade
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

### Install NTP and configure timezone to Helsinki
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
Restart jail2ban service and check that your sshd rule is enabled
```
$ sudo service fail2ban restart
$ sudo fail2ban-client status

Status
|- Number of jail:      1
`- Jail list:   sshd

```

### Install software that you need or is nice to have
```
$ sudo apt install curl git mysql-client tree pwgen
```

## Install docker-engine and docker-compose

### Install docker-engine
Source doc: https://docs.docker.com/engine/installation/linux/ubuntu/

Add docker to package list etc.
```
$ sudo apt-get install linux-image-extra-$(uname -r) \
    linux-image-extra-virtual \
    apt-transport-https \
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
This is good point to restart the server
```
$ sudo reboot
```

## Deploy

Extract environment
```
$ sudo tar -vxf /backup/<filename>.tar.xz -C /
```

Pull latest version
```
$ cd /docker/docker-server-stack/
$ sudo git pull
```
Start docker containers (fluent has to be first and proxy has to be last)
```
$ sudo docker-compose -f docker-compose.fluentd.yaml up -d
$ sudo docker-compose -f docker-compose.soivi.lamp.yaml up -d
$ sudo docker-compose -f docker-compose.kontiomaa.lamp.yaml up -d
$ sudo docker-compose -f docker-compose.soivi.wp.yaml up -d
$ sudo docker-compose -f docker-compose.kontiomaa.wp.yaml up -d
$ sudo docker-compose -f docker-compose.proxy.yaml up -d
```
Add backup go weekly
```
$ sudo mkdir /backup
$ sudoedit /etc/cron.weekly/docker_backup

#! /bin/bash
sudo tar cpfv /backup/$(date +"%Y%m%d-%H%M%S")_docker.tar.xz -I 'xz -9' /docker
```

## Useful commands

Stop docker-compose file containers
```
$ sudo docker-compose -f <filename>.yaml stop
```
Delete docker-compose file containers and volumes
```
$ sudo docker-compose -f <filename>.yaml rm -v
```
Stop all containers
```
$ sudo docker stop $(sudo docker ps -a -q)
```
Delete all containers and volumes
```
$ sudo docker rm -v $(sudo docker ps -a -q)
```
Delete all images
```
$ sudo docker rmi $(sudo docker images -q)
```
## Changing MySQL password

Find out containers IP address
```
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_name>
```
Change password
```
$ mysqladmin -u <user> -p'<old_password>' password '<new_password>' -h <ip-address>
```
Test new password
```
$ mysql -u <user> -p -h <ip-address>
```
