# This is used only for development to simulate the https loadbalancer

FROM nginx

COPY nginx-selfsigned.crt /etc/ssl/certs/
COPY nginx-selfsigned.key /etc/ssl/private/

COPY default-ssl.conf /etc/nginx/conf.d/default-ssl.conf

EXPOSE 443
