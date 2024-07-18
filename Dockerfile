FROM php:8.3-fpm

WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    libzip-dev \
    libxml2-dev \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    libyaz-dev \
    openssh-client \
    curl \
    vim \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev  \
    libonig-dev \
    libicu-dev \
    libpq-dev

# Git config
RUN mkdir ~/.ssh
COPY id_rsa  ~/.ssh/id_rsa
RUN chmod 700  ~/.ssh/id_rsa && eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa

# Install extensions
RUN docker-php-ext-install pgsql pdo_pgsql mbstring zip exif pcntl
RUN docker-php-ext-configure gd 
RUN docker-php-ext-configure intl
RUN docker-php-ext-install gd intl

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Prepare App
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer create-project --no-interaction drupal/recommended-project .
RUN composer require drush/drush
ENV PATH=${PATH}:/var/www/html/vendor/bin
# RUN groupadd nginx -g 1000
# RUN useradd nginx -u 1000 -g 1000
# RUN chown nginx:nginx -R  /var/www/html/*
# RUN chmod 777 /var/www/html/web/sites/default/files -R

# Defiend Port
EXPOSE 9000

# Run PHP-FPM
CMD ["php-fpm"]
