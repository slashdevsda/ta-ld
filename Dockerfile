FROM debian:stretch
ENV KANBOARD_VERSION=1.2.10

# Apache & misc prerequisites
RUN     LC_ALL=C.UTF-8 apt-get update; \
        apt-get install -y apache2 git libapache2-mod-fastcgi \
        php-cli php-mbstring git unzip; \
        # This package provides the add-apt-repository binary
        apt-get install -y software-properties-common; \
#        add-apt-repository -s ppa:ondrej/php; \
        apt-get update; 

RUN     wget https://github.com/kanboard/kanboard/archive/v$KANBOARD_VERSION.tar.gz; \
        tar xzvf v$version.tar.gz -C /var/www/; \
        chown -R www-data:www-data /var/www/kanboard-$KANBOARD_VERSION/data

ADD     kanboard /var/www/kanboard
