FROM trafex/php-nginx:3.8.0

USER root

RUN <<EOF
apk add composer
composer require fzaninotto/faker
EOF

RUN <<EOF
rm /var/www/html/*
sed -i 's/8080/8000/' /etc/nginx/conf.d/default.conf
EOF

COPY index.php /var/www/html/index.php

USER nobody
