FROM debian:bookworm-slim

# install apache
RUN <<EOF
apt-get update
apt-get install -y wget libapache2-mod-php8.2 php8.2-sqlite3 php8.2-dom php8.2-gd bzip2
EOF

WORKDIR /tmp
RUN <<EOF
# clean default apache index
rm /var/www/html/*

# download+extract phpbb
wget https://download.phpbb.com/pub/release/3.3/3.3.14/phpBB-3.3.14.tar.bz2
tar jxvf phpBB-3.3.14.tar.bz2
mv phpBB3/* /var/www/html/
mv phpBB3/.htaccess /var/www/html/

# ensure nothing left behind = directory is empty
rmdir phpBB3
rm phpBB*

# rights
chmod 666 /var/www/html/config.php
chmod 777 /var/www/html/store /var/www/html/cache /var/www/html/files /var/www/html/images/avatars/upload

# finish phpbb "installation"
rm -r /var/www/html/install

# db
mkdir /var/www/db
touch /var/www/db/bread.sqlite3
chown -R www-data:www-data /var/www/db
EOF

COPY phpbb-config.php /var/www/html/config.php

CMD bash -c 'service apache2 start && sleep infinity'

