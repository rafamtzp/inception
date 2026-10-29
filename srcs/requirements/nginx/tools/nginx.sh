
if [! -f /etc/nginx/ssl/inception.crt ]; then
	openssl req \
	-x509 \ #generate a self-signed certificate. Not a certificate request!
	-nodes \ #"no DES" = no passphrase for priv key
	-days 365 \ #certificate lifespan
	-newkey rsa:2048 \ #new priv key 2048 bits long using rsa at the same time it generates cetificate
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=ES/ST=Andalusia/L=Malaga/O=42/CN=ramarti2.42.fr" #mandatory metadata for my organization

	chmod 600 /etc/nginx/ssl/inception.key
	chmod 644 /etc/nginx/ssl/inception.crt
fi

exec nginx -g "daemon off;"
# exec ensures nginx becomes the main process which Docker monitors. Not bash.  The "daemon off" option allows nginxto keep running in the foreground as the main process so that Docker can manage it. Docker only sends signals to the main process (PID 1) inside each container.

# In a normal computer, PID 1 is systemd which manages other processes.  But in containers, the main running service is PID 1.
	
