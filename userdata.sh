#!/bin/sh
sudo -i
yum update -y
yum install -y httpd24 php56 php56-mysqlnd mysql55-server mysql git 
service httpd start
service mysqld start
chkconfig httpd on
chkconfig mysqld on

cd /var/www/html
git clone -b MOODLE_23_STABLE git://git.moodle.org/moodle.git 
chown -R root /var/www/html/moodle 
chmod -R 0755 /var/www/html/moodle
mkdir /var/www/moodledata 
chmod 0777 /var/www/moodledata 
chown root /var/www/moodledata

sudo /usr/bin/mysqladmin -u root password 'mysql'
#mysql --user=root --password=mysql
#CREATE DATABASE moodle DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; 
#GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO moodleuser@localhost IDENTIFIED BY 'yourpassword';
mysql --user=root --password=mysql <<_EOF_
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
  CREATE DATABASE moodle DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; 
  GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO moodleuser@localhost IDENTIFIED BY 'moodledbpassword'; 
_EOF_

wget https://s3.us-east-2.amazonaws.com/moodledb2018/dump.sql
mysql -u root --password="mysql" moodle < dump.sql

#wget https://s3.us-east-2.amazonaws.com/moodledb2018/moodle-3.3.5.tgz
#tar -zxvf moodle-3.3.5.tgz
#cp -r moodle /var/www/html
#chown -R root /var/www/html/moodle
#chmod -R 0755 /var/www/html/moodle
#mkdir /var/www/moodledata
#chmod 0777 /var/www/moodledata
#chown root /var/www/moodledata


