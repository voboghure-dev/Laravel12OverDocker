# ========================
# PHP + Apache + Laravel Dockerfile
# ========================

FROM php:8.3-apache

# -----------------------
# 1. Set document root
# -----------------------
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf \
    && sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy custom Apache virtual host config
COPY ./pos-with-laravel.conf /etc/apache2/sites-available/pos-with-laravel.conf

# Enable Laravel site + mod_rewrite
RUN a2ensite pos-with-laravel.conf \
    && a2dissite 000-default.conf \
    && a2enmod rewrite

# -----------------------
# 2. PHP configs
# -----------------------
COPY ./opcache.ini "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
COPY ./xdebug.ini "$PHP_INI_DIR/conf.d/99-xdebug.ini"
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# -----------------------
# 3. System deps + PHP extensions
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
    unzip \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install intl opcache pdo_mysql zip gd \
    && pecl install xdebug apcu-5.1.24 \
    && docker-php-ext-enable xdebug apcu \
    && echo "apc.enable=1" >> "$PHP_INI_DIR/php.ini" \
    && echo "apc.enable_cli=1" >> "$PHP_INI_DIR/php.ini"

# -----------------------
# 4. Create a user with dynamic UID/GID
# -----------------------
ARG UID=1000
ARG GID=1000
ARG UNAME=dev
RUN groupadd -g $GID $UNAME \
    && useradd -m -u $UID -g $GID -s /bin/bash $UNAME

# -----------------------
# 5. Install Composer as non-root user
# -----------------------
RUN mkdir -p /home/$UNAME/.local/bin
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/home/$UNAME/.local/bin --filename=composer
ENV PATH="/home/$UNAME/.local/bin:${PATH}"

# -----------------------
# 6. Install NVM + Node + NPM as non-root user
# -----------------------
USER $UNAME
ENV NVM_DIR=/home/$UNAME/.nvm
ENV NODE_VERSION=20.19.4
RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && npm install -g npm@latest
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# -----------------------
# 7. Laravel installer
# -----------------------
RUN composer global require laravel/installer
ENV PATH="/home/$UNAME/.composer/vendor/bin:/home/$UNAME/.config/composer/vendor/bin:${PATH}"

# -----------------------
# 8. Cleanup
# -----------------------
USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------
# 9. Set working directory & final user
# -----------------------
WORKDIR /var/www/html
USER $UNAME
