FROM debian:bookworm

RUN apt-get update && apt-get install -y \
 	php-fpm \
	php-mysql \ # lets PHP connect to db
	php-curl \ # used by wp for http requests
	php-gd \ # needed to handle images, text, and feeds
	php-mbstring \
	php-xml \
	php-zip \ # needed to install plugins/themes packaged as .zip
	curl \ # for downloading WP-CLI later
	mariadb-client \ # provides mysqladmin/mysql to check DB readiness
	&& rm -rf /var/lib/apt/lists/*

# Install wordpress CLI (needed to install and configure wordpress via commands)
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x /usr/local/bin/wp

# copy over our own config into php-fpm's "pool config" which determines the behavior of the php-fpm worker processes. It also allows us to define the user and group as www-data (which we need), and importantly, allows us to listen on a TCP socket on port 9000 rather than a UNIX socket by default so it can communicate with the nginx container.
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# copy over script
COPY tools/wordpress.sh /usr/local/bin/wordpress.sh

#document port
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]

