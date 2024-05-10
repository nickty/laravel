FROM php:8.2-fpm

# Set the working directory
WORKDIR /var/www

# Copy Composer files
COPY composer.lock composer.json /var/www/

# Install system dependencies including libonig-dev for the mbstring extension
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libzip-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \ 
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql mbstring zip exif pcntl

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# Create a new user 'www' with specified user and group IDs
RUN groupadd -g 1000 www \
    && useradd -u 1000 -ms /bin/bash -g www www

# Copy the application directory and adjust permissions
COPY --chown=www:www . /var/www/

# Change to non-root user
USER www

# Expose port 9000
EXPOSE 9000

# Command to run the PHP FPM server
CMD ["php-fpm"]
