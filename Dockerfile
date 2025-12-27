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
    openssh-client \
    curl \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev  \
    libonig-dev \
    libicu-dev \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        pgsql \
        pdo_pgsql \
        pdo_mysql \
        mbstring \
        zip \
        exif \
        pcntl \
        opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=256'; \
		echo 'opcache.interned_strings_buffer=16'; \
		echo 'opcache.max_accelerated_files=20000'; \
		echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.enable=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Prepare App
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer create-project --no-interaction drupal/recommended-project .
RUN composer require drush/drush

ENV PATH=${PATH}:/var/www/html/vendor/bin

# Fix permissions
RUN mkdir -p web/sites/default/files \
    && chown -R www-data:www-data web/sites/default/files \
    && chmod -R 775 web/sites/default/files \
    && chown -R www-data:www-data /var/www/html

# Defined Port
EXPOSE 9000

# Run PHP-FPM
CMD ["php-fpm"]
