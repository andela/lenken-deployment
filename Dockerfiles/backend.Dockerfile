FROM php:7.1

# Install Composer and make it available in the PATH
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo pdo_pgsql
# Set the WORKDIR to /usr/src so all following commands run in /app
RUN mkdir -p /usr/php/src
COPY . /usr/php/src
WORKDIR /usr/php/src

# Install dependencies with Composer.
RUN composer install
# RUN php artisan migrate 
# RUN php artisan db:seed
EXPOSE 3000
# Start the app on port 3000
CMD php -S 0.0.0.0:3000 -t public
