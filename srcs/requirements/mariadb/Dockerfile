FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/mysql/* \
    && rm -rf /var/lib/apt/lists/*

# /var/lib/mysql/* is removed bc the package's post-install script creates data in this folder which gets copied to our named volume by Docker and makes our script think the database is already initialized.

RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY tools/mariadb.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mariadb.sh

EXPOSE 3306

# putting cmds as a list of the form [""], causes Docker to pass the commands directly to the linux kernel using the exec syscall which makes our command be PID 1.  Not doing this would cause it to execute within a shell and so the shell itself would be PID 1. 
ENTRYPOINT ["/usr/local/bin/mariadb.sh"]
