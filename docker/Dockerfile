FROM webdevops/php-nginx:7.3-alpine
LABEL maintainer="iqbalnurimansyah@gmail.com"

RUN apk add python3 python3-dev py3-pip build-base libressl-dev musl-dev libffi-dev
RUN pip3 install pip --upgrade
RUN pip3 install certbot-nginx
RUN mkdir /etc/letsencrypt


#copy source code to container
WORKDIR /var/www/
COPY ./src/assetnest-backend  ./assetnest-backend
COPY ./src/assetnest-frontend/build/ ./assetnest-frontend/

#composer install depencdency
WORKDIR /var/www/assetnest-backend/
RUN composer update

WORKDIR /var/www/assetnest-backend/public/
RUN chmod -R 777 upload

#copy nginx server block
WORKDIR /opt/docker/etc/nginx/conf.d/
COPY ./nginx/default.conf .

EXPOSE 80 443

WORKDIR /var/www/
