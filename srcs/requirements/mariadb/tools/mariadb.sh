#!/bin/bash

#stop if cmd fails
set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# if this directory was not created then it's the first startup of mariadb.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # first startup of background server to initialize everything
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    #mysqld_safe is a wrapper script mariadb provides to start mysqld with extra safety precautions. The '&' in bash tells Linux to run that command in the background asynchronously
    mysqld_safe --datadir=/var/lib/mysql &

    #check connection to db
    until mysqladmin ping --silent; do
        sleep 1
    done

    DB_ROOT_PASSWORD=$(cat "${MYSQL_ROOT_PASSWORD_FILE}")
    DB_PASSWORD=$(cat "${MYSQL_PASSWORD_FILE}")

    # database creation
    echo "Creating database: ${MYSQL_DATABASE} for user: ${MYSQL_USER}"
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
#Note: '%' = any host
    #stop the background server
    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
fi

# start actual mariadb process in the foreground as PID 1
# config file should be used to set any needed parameters
exec mysqld --user=mysqld --datadir=/var/lib/mysql
