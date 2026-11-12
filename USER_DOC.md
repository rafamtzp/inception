# User Doc

---

## Services

The main services used in this stack are NGINX, WordPress with PHP-FPM, and Maria DB.

* **What is Nginx?**
    Nginx is a web server.  It listens on port 80/443 and handles HTTP/HTTPS requests.  If the request is secure, it decrypts it using TLS (with its SSL certificate).  In our case, it reformats this HTTP request into a FastCGI request.  Nginx is fast at handling several requests simultaneously because it has a parent process that manages several worker processes that are always running and listening for requests.  It also has more features such as load balancing (evenly distribute requests to multiple backend services) and caching (keeping a frequently-requested resource available at all times).

* **What is FastCGI?**
    A protocol that defines a specific organized format that is easy for backend FastCGI process managers to process.  A FastCGI process manager is a program that receives these FastCGI requests on port 9000 and sends them to their pool of constantly running worker backend processes.  These processes then send whatever was requested back to the process manager which sends it to the web server that sent the request (Nginx).

* **What is PHP-FPM?**
    A. K. A. PHP FastCGI Process Manager.  It takes these FastCGI requests and sends them to processes that execute php scripts and return the requested content.

* **What is WordPress?**
    WordPress is just a set of HTML, CSS, JavaScript, and PHP files that can be run and used to build websites.  i.e. the set of utilities that generate websites.  In our case, PHP-FPM has processes that execute the PHP scripts provided by WordPress itself to generate websites.

* **What is MariaDB?**
    MariaDB is the database service that these WordPress scripts rely on to store data that keeps the content on the website from losing its status even after the website is shut down or restarted.  In this project, only WordPress communicates with it using port 3306.

* **What is each volume for?**
    In this project, you have two volumes: One that stores all the WordPress files and another for the MariaDB database which stores things like posts, profiles, usernames, passwords, etc.  The first is accessible to the PHP-FPM container since it needs the PHP scripts and to the Nginx container since it needs the static HTML, CSS, and JavaScript files.

---
## Usage

### Starting and Stopping The Project
To start the project, open the terminal and run

```bash
make
```

To stop the project and gracefully shut down all containers without losing persistent data, run:

```bash
make down
```

### Accessing the Website and Administration Panel

Once the containers are running and fully initialized:

* **Public Website:** Open your browser and navigate to https://ramarti2.42.fr. Note: Make sure you have mapped your login domain to 127.0.0.1 inside your local /etc/hosts file (see `DEV_DOC.md`).

* **WordPress Administration Panel:**  Navigate to https://ramarti2.42.fr/wp-admin to log into the WordPress dashboard.

By default the domain name should be ramarti2.42.fr. If you want to change the domain name see `DEV_DOC.md.` 

### Locating and Managing Credentials
**Locations:** Database and WordPress usernames and emails are configured securely using an environment file `.env` inside the `srcs/` folder.  Database and WordPress passwords should be in separate text files inside the `secrets` folder.

* **Management:** Administrators can view or update these credentials by editing the .env file before building or starting the containers. If you wish to change the passwords, retype the passwords inside the `secrets` folder.

### Check That The Services Are Running Correctly
To verify that all containers (nginx, wordpress, and mariadb) are up, healthy, and running as expected, you can run:

```
docker compose ps
```
or

```
docker ps
```
inside the `srcs/` folder.

All three services should show a status of Up (and Nginx/WordPress should show proper port mappings like 443 or internal network connectivity). You can also inspect container logs in real time using:

```
docker compose logs
```

in `srcs/` or 

```
make logs
```

in the root of the repository.
