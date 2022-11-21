FROM php:7.4-apache
LABEL maintainer="Kiran Parajuli <kiran@jankaritech.com> (@kiranparauli589)"

RUN php -m
RUN curl -sSLf \
    -o /usr/local/bin/install-php-extensions \
    https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions mysqli gd intl imagick zip xdebug ldap memcached redis apcu ast gmp
RUN php -m

RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils build-essential zsh neovim make unzip git curl openssl ufw
RUN sh -c "$(curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh")"
RUN exec zsh
RUN chsh -s $(which zsh)

RUN curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install -y nodejs
RUN npm install -g npm@latest
RUN npm install --global yarn

# configure ssl parameters
COPY apache/ssl-params.conf /etc/apache2/conf-available/ssl-params.conf

# configure v.hosts
COPY ./certs/ /tmp/certs
RUN cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak
COPY apache/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# ssl configurations
RUN a2enmod ssl
RUN a2enmod headers
RUN a2ensite default-ssl
RUN a2enconf ssl-params
RUN apache2ctl configtest

COPY apache/test.html /var/www/html/index.html
COPY apache/test.html /var/www/html/check/index.html

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# get owncloud with OAuth2 app
RUN git clone -b master --single-branch --depth 1 https://github.com/owncloud/core.git /var/www/html/owncloud
WORKDIR /var/www/html/owncloud
RUN make
RUN git clone https://github.com/owncloud/oauth2.git apps/oauth2
RUN make -C apps/oauth2 dist
RUN php ./occ maintenance:install -vvv --admin-user=admin --admin-pass=admin --data-dir=/var/www/html/owncloud/data
RUN chown www-data:www-data . -R
RUN php ./occ app:enable oauth2

# start apache
CMD ["apache2-foreground"]
