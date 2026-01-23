FROM php:8.2-apache

# 1. Installer les dépendances système nécessaires pour PostgreSQL et Composer
RUN apt-get update && apt-get install -y \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_pgsql

# 2. Installer Composer proprement dans l'image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Activer le module de redirection d'Apache
RUN a2enmod rewrite

# 4. Définir le répertoire de travail
WORKDIR /var/www/html

# 5. Copier les fichiers du projet Laravel
COPY . .

# 6. Installer les dépendances PHP (le dossier vendor va être créé ici)
RUN composer install --no-dev --optimize-autoloader --no-scripts

# 7. Configurer Apache pour pointer vers le dossier /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 8. Donner les droits sur les dossiers de cache et logs
RUN chown -R www-data:www-data storage bootstrap/cache

# 9. Exposer le port 80
EXPOSE 80


# 10. Lancer les migrations et démarrer le serveur
# À la fin de ton Dockerfile
CMD php artisan config:clear && php artisan migrate --force && apache2-foreground
