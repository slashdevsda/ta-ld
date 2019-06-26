FROM debian:stretch
ENV KANBOARD_VERSION=1.2.10
ENV KANBOARD_DB_USERNAME=kanboard
ARG KANBOARD_DB_PASSWD=notoverriden
ENV KANBOARD_DB_HOST=db

# Apache & misc prerequisites
RUN     LC_ALL=C.UTF-8 apt-get update; \
        apt-get install -y apache2 \
        ;

RUN apt-get install -y wget git unzip \
        php7.0 php7.0-fpm libapache2-mod-php7.0 \
        php7.0-pdo-sqlite php7.0-pdo-mysql \
        php7.0-gd \
        php7.0-imap \
        php7.0-xml \
        php7.0-curl \
        php7.0-mbstring;

RUN     wget https://github.com/kanboard/kanboard/archive/v$KANBOARD_VERSION.tar.gz; \
        tar xzvf v$KANBOARD_VERSION.tar.gz -C /var/www/; \
        chown -R www-data:www-data /var/www/kanboard-$KANBOARD_VERSION/data; \
        rm -rfv /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*;

COPY    configs/001-kanboard.conf /etc/apache2/sites-available/

RUN     sed -i 's/^/#&/g' /etc/apache2/site-available/000-default.conf; \
        sed -s "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf; \
        sed -i "s/{KANBOARD_VER}/kanboard-$KANBOARD_VERSION/g" /etc/apache2/sites-available/001-kanboard.conf; \
        cd /etc/apache2/sites-enabled/ && ln -s /etc/apache2/sites-available/001-kanboard.conf;

RUN     cp /var/www/kanboard-$KANBOARD_VERSION/config.default.php /var/www/kanboard-$KANBOARD_VERSION/config.php; \
        sed -i "s/define('DB_DRIVER', 'sqlite')/define('DB_DRIVER', 'mysql')/g" /var/www/kanboard-$KANBOARD_VERSION/config.php; \
        sed -i "s/define('DB_USERNAME', 'root')/define('DB_USERNAME', '$KANBOARD_DB_USERNAME')/g" /var/www/kanboard-$KANBOARD_VERSION/config.php; \
        sed -i "s/define('DB_PASSWORD', '')/define('DB_PASSWORD', '$KANBOARD_DB_PASSWD')/g" /var/www/kanboard-$KANBOARD_VERSION/config.php; \
        sed -i "s/define('DB_HOSTNAME', 'localhost')/define('DB_HOSTNAME', '$KANBOARD_DB_HOST')/g" /var/www/kanboard-$KANBOARD_VERSION/config.php;

CMD     apachectl -d /etc/apache2/ -f /etc/apache2/apache2.conf -e info -DFOREGROUND
EXPOSE  80
