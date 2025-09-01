FROM debian:bookworm-slim

# install apache
RUN <<EOF
apt-get update
apt-get install -y wget libapache2-mod-php8.2 php8.2-sqlite3 php8.2-dom php8.2-gd bzip2 unzip patch sqlite3
EOF

WORKDIR /tmp
RUN <<EOF
# clean default apache index
rm /var/www/html/*

# download+extract phpbb
wget -q https://download.phpbb.com/pub/release/3.3/3.3.14/phpBB-3.3.14.tar.bz2
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
EOF

COPY 2fa-patches/* /tmp/
RUN <<EOF
# install extension
wget -q "https://www.phpbb.com/customise/db/download/183726" -O /var/www/html/ext/2fa.zip
cd /var/www/html/ext/
unzip 2fa.zip
rm 2fa.zip

# apply patches to introduce TOTP bruteforce possibility
cd /tmp
patch -p1 --directory=/var/www/html/ext/paul999/tfa <2fa.patch
patch -p1 --directory=/var/www/html/ <phpbb-functions.patch
rm *.patch
EOF

COPY db-dump /tmp/db-dump
RUN <<EOF
echo "Restoring DB, this might take a while"
mkdir /var/www/db
cd /tmp/db-dump
bash -c 'cat *.sql | sqlite3 /var/www/db/bread.sqlite3'
chown -R www-data:www-data /var/www/db
rm -r /tmp/db-dump
EOF

COPY phpbb-config.php /var/www/html/config.php
COPY attachments/tx-confirmation.jpg /var/www/html/files/59_e09531b3d562bcce937839c5920faa71
COPY attachments/flag.txt /var/www/html/files/64_4c86a649b79d1f9a6d241e50019e0e98

CMD bash -c 'service apache2 start && sleep infinity'

