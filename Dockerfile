FROM ubuntu:18.04
MAINTAINER Wesley Haegens <wesley@weha.be>

# Add basics first
RUN apt -y install bash curl ca-certificates openssl git tzdata nano software-properties-common \
	&& add-apt-repository -y ppa:ondrej/php \
	&& apt update \
	&& apt -y upgrade \
	&& apt -y install apache2 php
	
# Add Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Setup apache and php
RUN apt -y install php-common php-xdebug php-mbstring php-soap php-zip php-mysql php-sqlite3 php-pgsql php-bcmath php-gd php-odbc php-gettext php-tokenizer php-xmlrpc php-bz2 php-curl php-redis php-intl php-ldap php-apcu php-imap php-phalcon php-imagick

# Add apache to run and configure
RUN echo '*** Apache modules...' \
	&& a2enmod rewrite_module session_module session_cookie_module session_crypto_module deflate_module unique_id_module cache_module cache_socache_module http2_module \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/var/www/html\"#g" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#/var/www/html#" /etc/apache2/httpd.conf \
    && printf "\n<Directory \"/var/www/html\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf

RUN mkdir /var/www/html && chown -R apache:apache /var/www/html && chmod -R 755 /var/www/html && mkdir bootstrap

ADD start.sh /bootstrap/
RUN chmod +x /bootstrap/start.sh

VOLUME /var/www/html
VOLUME /etc/apache2/sites-enabled

EXPOSE 80
ENTRYPOINT ["/bootstrap/start.sh"]
WORKDIR /etc/apache2/
