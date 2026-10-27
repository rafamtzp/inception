FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl

EXPOSE 80 443

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]

