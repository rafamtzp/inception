FROM debian:bookworm

#update and install nginx and openssl (required to generate ssl certificate).
RUN apt-get update && apt-get install -y nginx openssl \
&& rm -rf /var/lib/apt/lists/* #Remove apt cache

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/nginx.sh /usr/local/bin/nginx.sh

RUN chmod +x /usr/local/bin/nginx.sh

EXPOSE 443

ENTRYPOINT ["nginx.sh"]

#Difference between CMD and ENTRYPOINT: CMD specifies the default command to be run but can be completely overriden by parameters passed on to docker run.  ENTRYPOINT on the other hand is a default command that can never be overriden without the --entrypoint flag in docker run and any arguments supplied to docker run are appended to this command.
