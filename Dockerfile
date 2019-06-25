FROM debian:stretch
ENV KANBOARD_VERSION=1.2.10

# Apache & misc prerequisites
RUN     LC_ALL=C.UTF-8 apt-get update; \
        apt-get install -y apache2 \
        ;

RUN apt-get install -y wget git unzip \
        php7.0 php7.0-fpm libapache2-mod-php7.0 \
        php7.0-pdo-sqlite php7.0-pdo-pgsql \
        php7.0-gd \
        php7.0-imap \
        php7.0-xml \
        php7.0-curl \
        php7.0-mbstring;


# This package provides the add-apt-repository binary
#        apt-get install -y software-properties-common; \
#        add-apt-repository -s ppa:ondrej/php; \


RUN     wget https://github.com/kanboard/kanboard/archive/v$KANBOARD_VERSION.tar.gz; \
        tar xzvf v$KANBOARD_VERSION.tar.gz -C /var/www/; \
        chown -R www-data:www-data /var/www/kanboard-$KANBOARD_VERSION/data; \
        rm -rfv /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*;


COPY    configs/001-kanboard.conf /etc/apache2/sites-available/

RUN     sed -i 's/^/#&/g' /etc/apache2/site-available/000-default.conf; \
        sed -s "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf; \
        sed -i "s/{KANBOARD_VER}/kanboard-$KANBOARD_VERSION/g" /etc/apache2/sites-available/001-kanboard.conf; \
        cd /etc/apache2/sites-enabled/ && ln -s /etc/apache2/sites-available/001-kanboard.conf;

CMD     apachectl -d /etc/apache2/ -f /etc/apache2/apache2.conf -e info -DFOREGROUND
EXPOSE 80
