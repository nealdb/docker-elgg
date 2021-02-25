FROM ubuntu:bionic
ENV TZ=Europe/London
ENV VER=3.3.16
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  && apt-get update \
  && apt-get install -y php \
    php7.2 \
    libapache2-mod-php7.2 \
    php7.2-common \
    php7.2-sqlite3 \
    php7.2-curl \
    php7.2-intl \
    php7.2-mbstring \
    php7.2-xmlrpc \
    php7.2-mysql \
    php7.2-gd \
    php7.2-xml \
    php7.2-cli \
    php7.2-zip \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

RUN cd /tmp \
  && wget -O elgg.zip https://elgg.org/about/getelgg?forward=elgg-$VER.zip \
  && rm /var/www/html/index.html \
  && ln -s /var/www/html elgg-$VER \
  && unzip elgg.zip \
  && rm elgg.zip \
  && rm /tmp/elgg-$VER
RUN     { \
                echo '<VirtualHost *:80>'; \
                echo '     DocumentRoot /var/www/html/'; \
                echo '     ServerName example.com'; \
                echo '     <Directory /var/www/html/>'; \
                echo '          Options FollowSymlinks'; \
                echo '          AllowOverride All'; \
                echo '          Require all granted'; \
                echo '     </Directory>'; \
                echo '     ErrorLog ${APACHE_LOG_DIR}/elgg-error.log'; \
                echo '     CustomLog ${APACHE_LOG_DIR}/access.log combined'; \
                echo '</VirtualHost>'; \
        } > /etc/apache2/sites-available/elgg.conf

RUN mkdir -p /var/www/html/data \
  && chown -R www-data:www-data /var/www/html/ \
  && chmod -R 755 /var/www/html/ \
  && a2enmod rewrite \
  && a2ensite elgg.conf


EXPOSE 80
CMD apachectl -D FOREGROUND

