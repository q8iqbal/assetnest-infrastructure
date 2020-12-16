FROM webdevops/php-nginx:7.3-alpine
LABEL maintainer="iqbalnurimansyah@gmail.com"

#copy source code to container
WORKDIR /var/www/
COPY ./src/assetnest-backend  ./assetnest-backend
COPY ./src/assetnest-frontend/build/ ./assetnest-frontend/

#composer install depencdency
WORKDIR /var/www/assetnest-backend/
RUN composer update

#copy nginx server block
WORKDIR /opt/docker/etc/nginx/conf.d/
COPY ./nginx/default.conf .

EXPOSE 80 443

WORKDIR /var/www/
