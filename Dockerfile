FROM php:8.3-apache

# -----------------------
# 1. Set document root
# -----------------------
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf && \
    sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy custom Apache virtual host config
COPY ./pos-with-laravel.conf /etc/apache2/sites-available/pos-with-laravel.conf

# Enable Laravel site + mod_rewrite
RUN a2ensite pos-with-laravel.conf \
    && a2dissite 000-default.conf \
    && a2enmod rewrite

# -----------------------
# 2. Copy PHP configs
# -----------------------
COPY ./opcache.ini "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
COPY ./xdebug.ini "$PHP_INI_DIR/conf.d/99-xdebug.ini"
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# -----------------------
# 3. Install system deps + PHP extensions
# -----------------------
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    zip \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    git \
    curl \
    bash \
    nano \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install intl opcache pdo_mysql zip gd \
    && pecl install xdebug apcu-5.1.24 \
    && docker-php-ext-enable xdebug apcu \
    && echo "apc.enable=1" >> "$PHP_INI_DIR/php.ini" \
    && echo "apc.enable_cli=1" >> "$PHP_INI_DIR/php.ini"

# -----------------------
# 4. Install Composer
# -----------------------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# -----------------------
# 5. Install NVM + Node + NPM
# -----------------------
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=20.19.4
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && npm install -g npm@latest

# Add Node/NPM to PATH for all shells
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# -----------------------
# 6. Laravel installer (optional)
# -----------------------
RUN composer global require laravel/installer

# -----------------------
# 7. Cleanup
# -----------------------
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html
