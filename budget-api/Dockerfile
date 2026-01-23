FROM php:8.2-apache

# Installer les dépendances système et PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Activer le module rewrite d'Apache
RUN a2enmod rewrite

# Copier les fichiers du projet
COPY . /var/www/html

# Configurer le DocumentRoot sur le dossier public de Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Donner les permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Commande magique pour migrer et lancer Apache
CMD php artisan migrate --force && apache2-foreground

# Exposer le port 80
EXPOSE 80
