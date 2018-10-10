#!/bin/bash



secureMYSQL() {

	echo "Getting temp password"
	grep 'A temporary password is generated for root@localhost' /var/log/mysqld.log |tail -1 > temppassword.txt
	passwd="`grep 'temporary.*root@localhost' temppassword.txt | sed 's/.*root@localhost: //'`"

	echo "temporary password is: $passwd"
	echo "starting secure installation"

	SECURE_MYSQL=$(expect -c "
	set timeout 10
	spawn /usr/bin/mysql_secure_installation
	expect \"Enter password for user root:\"
	send \"$passwd\r\"
	expect \"New password: \"
	send \"$MYSQL_ROOT_PASSWORD\r\"
	expect \"Re-enter new password: \"
	send \"$MYSQL_ROOT_PASSWORD\r\"
	expect \"Change the password for root ? ((Press y|Y for Yes, any other key for No) : \"
	send \"n\r\"
	expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) : \"
	send \"n\r\"
	expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) : \"
	send \"n\r\"
	expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) : \"
	send \"n\r\"
	expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) : \"
	send \"y\r\"
	expect eof
	")

	echo "$SECURE_MYSQL"
}

installMYSQL() {
        echo "----------------- Starting Installation, Starting and Securing of mySQL ----------------- "

        echo "Installing expect"
        yum -y install expect

        echo "Installing mysql"
        yum -y localinstall https://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
        yum -y install mysql-community-server
        echo "Finished installing mysql"

        echo "Starting mysql"
        systemctl start mysqld.service

        echo "Securing mysql"
        secureMYSQL
		echo "Finished Securing mysql"

        echo "----------------- Finished  Installation, Starting and Securing of mySQL ----------------- "

}

createHDFmySQLDataStores() {

	echo "----------------- Started Creation HDF MYSQL Database and Tables  ----------------- "
	
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE DATABASE registry"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE DATABASE streamline"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE DATABASE druid DEFAULT CHARACTER SET utf8"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE DATABASE superset DEFAULT CHARACTER SET utf8"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE DATABASE streamsmsgmgr"
	
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE USER 'registry'@'%' IDENTIFIED BY '${REGISTRY_DB_PASSWORD}'"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE USER 'streamline'@'%' IDENTIFIED BY '${SAM_DB_PASSWORD}'"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE USER 'druid'@'%' IDENTIFIED BY '${DRUID_DB_PASSWORD}'"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE USER 'superset'@'%' IDENTIFIED BY '${SUPERSET_DB_PASSWORD}'"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="CREATE USER 'streamsmsgmgr'@'%' IDENTIFIED BY '${SMM_DB_PASSWORD}'"
	
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="GRANT ALL PRIVILEGES ON registry.* TO 'registry'@'%' WITH GRANT OPTION"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="GRANT ALL PRIVILEGES ON streamline.* TO 'streamline'@'%' WITH GRANT OPTION"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="GRANT ALL PRIVILEGES ON druid.* TO 'druid'@'%' WITH GRANT OPTION"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="GRANT ALL PRIVILEGES ON superset.* TO 'superset'@'%' WITH GRANT OPTION"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="GRANT ALL PRIVILEGES ON streamsmsgmgr.* TO 'streamsmsgmgr'@'%' WITH GRANT OPTION"

	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="FLUSH PRIVILEGES"
	mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --execute="COMMIT"
	
	
	echo "----------------- Finished Creation HDF MYSQL Database and Tables  ----------------- "	

}

installAndRegisterMySQLDriver() {

	echo "----------------- Started Download of mysql-connector started ----------------- "
	yum -y install mysql-connector-java*
	echo "----------------- Finished Download of mysql-connector started ----------------- "
	
	echo "----------------- Started registering of mysql-connector started ----------------- "
	ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
	echo "----------------- Finished registering of mysql-connector started ----------------- "
	
}

installMYSQL
createHDFmySQLDataStores
installAndRegisterMySQLDriver