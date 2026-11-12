# Developer Documentation

## Set Up Environment from Scratch (prerequisites, configuration files, secrets)

### 1. Prerequisites
Ensure the host machine (Debian/Ubuntu-based OS recommended) has the following packages installed:
* **Docker Engine** (`docker.io` or official Docker repository)
* **Docker Compose** plugin (`docker-compose-v2` or `docker compose` CLI support)
* **Make** build automation utility
* Sudo utility (normally included)

Make sure your current user is added to the `docker` group so Docker commands can be run without `sudo`:
```bash
sudo usermod -aG docker $USER
```
### 2. Create Secrets Folder
These services rely on specific Docker secrets (passwords) that must be created by the user.  No secrets are included in this repository for security reasons.

You can create the `secrets` folder and the necessary files (which must be filled in) by running
```
make secrets
```
or by doing it manually.  You should have the following text files inside:
```
db_password.txt - password for database
db_root_password.txt - root password for database
wp_user_password.txt - password for WordPress user
wp_admin_password.txt - password for WordPress admin
```
### 3. Create .env File for Environment Variables
These services require environment variables inside `srcs/.env/`.  There is a `.env.example` file which contains most of the required environment variables filled in.  However, we decided in the end to leave it up to the user of this repository to fill in their own usernames and emails for security reasons.

IMPORTANT: After filling in your desired values, rename the file to `.env` or copy everything over to a `.env` file in `srcs/`.

### 4. Add or Configure The Domain Name
If you wish to change the domain name of the web application, you must change the value of DOMAIN_NAME inside `srcs/.env`. By default the domain name should be `ramarti2.42.fr`.

If you want to use the domain name inside .env, go to `/etc/` and open the `hosts` file.  Then add the following line as sudo if it's not already there.

`127.0.0.1 <DOMAIN_NAME>`

---

## Where Project Data Is Stored
This project uses two Docker volumes mounted to two host directories.  The MariaDB database volume and the WordPress files volume.  They are both mounted to (relative to the root of the repository) `../data/mariadb` and `../data/wordpress`.  When containers are stopped everything in the container is deleted.  By having the data stored in volumes separate from these containers, we allow the data to persist in subsequent restarts.

---

## Build and Launch Project Using Makefile and Docker Compose
Here are the Makefile commands you can use to build and launch the project:
```
make build # To only build the images
make up # To build data directories and start containers
make #runs 'build' and 'up' and starts containers and volumes
```
These make commands use Docker and Docker Compose commands under the hood.  If you want to build and launch the project with Docker commands you have the following.

```
# Build container images from scratch without starting them
docker compose -f srcs/docker-compose.yml build

# Start services in detached (background) mode
docker compose -f srcs/docker-compose.yml up -d
```


## Commands to Manage Containers and Volumes
**Makefile Rules**
```
make down # To stop containers
make clean # Stops containers, deletes volumes, and deletes images (and anything left over)
make fclean # Runs make clean and deletes the data directories for MariaDB and WordPress
```

**Extra rules:**
```
make re #fclean and then rebuilds and restarts
make dirs #used to make only MariaDB and WordPress data directories
make cleandata #to delete data directories
make logs #shortcut to view container logs
```
**Regular Docker Commands:**
```
# List all currently running containers in the stack
docker ps

# List all containers (including stopped, exited, or crashed ones)
docker ps -a

# Display container resource usage statistics (CPU, Memory, Network I/O)
docker stats

# Stream live logs for all services combined
docker compose -f srcs/docker-compose.yml logs -f

# View logs for specific individual services
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb

# Access an interactive shell inside a running container for debugging
docker exec -it nginx /bin/sh
docker exec -it wordpress /bin/sh
docker exec -it mariadb /bin/bash

# List all Docker named volumes
docker volume ls

# Inspect volume metadata (verify mount points and host paths under /home/login/data)
docker volume inspect srcs_wordpress_files
docker volume inspect srcs_database

# List all Docker networks
docker network ls

# Inspect details of the custom bridge network (check IP allocations and connected containers)
docker network inspect srcs_inception-network

# Stop and remove running containers and networks
docker compose -f srcs/docker-compose.yml down

# Stop, remove containers, and purge associated named volumes
docker compose -f srcs/docker-compose.yml down -v
```
