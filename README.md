# docker-server-stack


$ mkdir -p ~/backup  
$ mysqldump -u user -p <database name> | gzip -9 > ~/backup/$(date +"%Y%m%d")_wordpress.sql.gz  
$ tar -zcvf ~/backup/$(date +"%Y%m%d")_wordpress-dir.tar.gz /home/user/public_html/wordpress  

sudo apt install mysql-client  
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockerserverstack_mysql-wp-soivi_1  
172.21.0.3  
mysql <database> -u <user> -p -h <ip> < ~/backup/20170109_wordpress.sql  


sudo chown -R 33:33 wordpress/  
sudo chmod -R 755 wp-content/  
