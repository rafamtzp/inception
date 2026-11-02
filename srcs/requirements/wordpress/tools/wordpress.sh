# stop script immediately if any command fails
set -e

# get passwords for configuration below
DB_PASSWORD=$(cat /run/secrets/db_password)
ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# check database works (I'm scared of infinite loops...)
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent; do
	sleep 1
done

# create wp config
if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "wp-config.php not found, downloading and configuring WordPress..."
	wp core download --path=/var/www/html --allow-root

	wp config create \
		--path=/var/www/html \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost=mariadb \
		--allow-root
else
	echo "wp-config.php already exists, skipping download and config."
fi

# Install wordpress and create admin
if wp user get "${WP_ADMIN}" --path=/var/www/html --allow-root > /dev/null 2>&1; then
	echo "Admin user already exists.  Skipping wp core install."
else
	echo "Admin user not found, running wp install..."
	wp core install \
		--path=/var/www/html \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_emial="${WP_ADMIN_EMAIL}" \
		--allow-root
	# Check again if everything was created successfully
	if wp user get "${WP_ADMIN}" --path=/var/www/html --allow-root > /dev/null 2>&1; then
		echo "Admin user created successfully."
	else
		echo "ERROR: failed to create admin. Aborting."
		exit 1
	fi
fi

# Create wp user
# Gets user and sends any outputs to /dev/null including errors. 
if wp user get "${WP_USER}" --path=/var/www/html --allow-root > /dev/null 2>&1; then
	echo "second user already exists, skipping wp user create."
else
	echo "Second user not found, creating..."
	wp user create \
		--path=/var/www/html \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--allow-root
	
	if wp user get "${WP_USER}" --path=/var/www/html --allow-root > /dev/null 2>&1; then
		echo "Second user created and verified successfully."
	else
		echo "ERROR: second user was not created correctly. Aborting."
		exit 1
	fi
fi

