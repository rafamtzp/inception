# stop script immediately if any command fails
set -e

# get passwords for configuration below
DB_PASSWORD=$(cat /run/secrets/db_password)
ADMIN_PASSWORD=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d '=' -f2-)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent; do
	sleep 1
done

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

if wp user get "${WP_USER}" --path=/var/www/html --allow-root > /dev/null 2>&1; then
	echo "second user already exists, skipping wp user create."
else
	echo "Second user not found, creating..."
	wp user create \
		--path=/var/www/html \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}"






