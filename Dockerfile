FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

### Install packages

RUN apt-get -y update && apt-get -y upgrade

### installs add-apt-repository
RUN apt-get -y install \
	software-properties-common \
	curl \
    vim \
    gosu \
	supervisor \
	php7.2-cli php7.2-dev php7.2-common \
	php7.2-mysql php7.2-pgsql \
	php7.2-json php7.2-curl php7.2-gd \
	php7.2-mbstring php7.2-zip \
	php7.2-fpm php7.2-xml php7.2-pdo\
	libpng-dev

### install nginx
RUN add-apt-repository -y ppa:nginx/stable && \
	apt-get -y update && \
	apt-get -y install nginx

#install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

#change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

### install node
RUN mkdir /node && \
    curl -sS https://nodejs.org/dist/v8.11.2/node-v8.11.2-linux-x64.tar.xz -o /node/node.tar.xz && tar -xJvf /node/node.tar.xz -C /node/ && rm /node/node.tar.xz
ENV NODEJS_HOME=/node/node-v8.11.2-linux-x64/bin
ENV PATH=$NODEJS_HOME:$PATH

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	apt-get -y update && apt-get -y install yarn

### PHP config
RUN echo "clear_env = no" >> /etc/php/7.2/fpm/php-fpm.conf && \
    sed -i "s/.*daemonize.*/daemonize = no/" /etc/php/7.2/fpm/php-fpm.conf && \
    service php7.2-fpm start

# set our application folder as an environment variable
ENV APP_HOME /var/www/html

COPY . $APP_HOME
WORKDIR $APP_HOME

RUN cp -n .env.example .env

RUN chown -R www-data:www-data $APP_HOME && \
    yarn && yarn install --production && rm -rf node_modules

RUN gosu www-data composer install --no-ansi --no-interaction --no-progress --no-scripts --optimize-autoloader --working-dir=$APP_HOME

COPY dockerfiles/supervisord.conf /etc/supervisor/supervisord.conf
COPY dockerfiles/start.sh /start.sh
COPY dockerfiles/php-fpm-wrapper.sh /php-fpm-wrapper.sh
COPY php.ini /etc/php/7.2/fpm/php.ini
COPY dockerfiles/nginx.default /etc/nginx/sites-available/default
COPY dockerfiles/www.conf /etc/php/7.2/fmp/pool.d/www.conf

### change ownership of our applications
RUN chown -R www-data:www-data /var/www && \
    chown -R www-data:www-data /var/log/nginx && \
    chown -R www-data:www-data /var/lib/nginx && \
    chown -R www-data:www-data /etc/nginx/nginx.conf && \
    chown -R www-data:www-data /etc/nginx/sites-enabled

RUN chmod +x /start.sh && \
    chmod +x /php-fpm-wrapper.sh

CMD "/start.sh"
EXPOSE 80 443
