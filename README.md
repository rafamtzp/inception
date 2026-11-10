---

*This project has been created as part of the 42 curriculum by ramarti2.*

# Inception

---

## Description

**Inception** is a system administration project that introduces containerization using Docker. The goal of this project is to build a secure, multi-container infrastructure from scratch using custom Dockerfiles and Docker Compose, ensuring strict adherence to system administration best practices and container isolation rules.

The stack consists of three core services running on a custom Docker network (`inception-network`):
1. **Nginx:** Acts as the single entry point for the infrastructure, handling incoming HTTPS traffic securely via TLSv1.3 and proxying PHP requests to WordPress.
2. **WordPress + PHP-FPM:** A modern WordPress installation managed via WP-CLI, communicating with PHP-FPM over TCP port 9000.
3. **MariaDB:** A dedicated relational database backend configured with custom user permissions, persistent host-bound data directories, and secure credential handling via Docker secrets.

---

## Instructions

### Prerequisites
* A Linux-based environment (or virtual machine) with Docker and Docker Compose installed.
* Sudo privileges (required for managing file permissions on host bind-mount volumes).

### Configuration
The project comes with a `Makefile` at the root directory to automate building and managing the infrastructure.

Run the following command in the terminal
  ```bash
  make secrets
  ```
This will create the `secrets/` directory and the files where you should type the passwords you want to use.  You have
   * `secrets/db_password.txt` for your database password,
   * `secrets/db_root_password.txt` for your root database user's password,
   * `secrets/wp_admin_password.txt` for your WordPress admin's password,
   * `secrets/wp_user_password.txt` for your WordPress user's password.

You must fill these in yourself.  No sensitive passwords are included in this repository.

IMPORTANT: There is a `.env` file in `srcs/` which contains values for usernames, emails, password file paths, etc. Make sure to replace some of these placeholder (working) values with your desired values.  No passwords or sensitive credentials are contained in this .env.

### Execution
* **Build and start the stack:**
  ```bash
  make

```
* **Start (or restart) an already-built Stack
```bash
make up
```

* **Stop the stack:**
```bash
make down

```

* **Clean containers and networks:**
```bash
make clean

```

* **Complete teardown (destroys containers, images, volumes, and data directories):**
```bash
make fclean

```
There are more commands you can use with `make` such as `logs` to view the Docker Compose logs, `dirs` to just create the data directories, `cleandata` to delete the directories, `build` to only build the images and create directories, and `re` to tear down and rebuild everything. 

Once running, you can access your site by adding your domain (e.g., `ramarti.42.fr`) to your local `/etc/hosts` file mapped to `127.0.0.1`, and navigating to `https://ramarti.42.fr` in your browser.

You do this (if I remember correctly) by pasting the following line at the top of the `/etc/hosts` file:
```
127.0.0.1 ramarti2.42.fr
```

---

## Resources & AI Usage

### Resources
* [Official Docker Documentation](https://docs.docker.com/)
* [Docker Compose File Reference](https://docs.docker.com/reference/compose-file/)
* [Dockerfile Reference](https://docs.docker.com/reference/dockerfile/)
* [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
* [MariaDB Docs](https://mariadb.com/docs/)
* [NGINX Docs](https://nginx.org/en/docs/)
* [NGINX FastCGI Module](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)
* [WordPress CLI Commands](https://developer.wordpress.org/cli/commands/)
* [openssl Docs](https://docs.openssl.org/master/man1/openssl-req/#options)
* [Inception Conceptual Guide](https://devabdilah.medium.com/inception-42-a-comprehensive-guide-to-dockerizing-your-first-infrastructure-part-iii-a10e93e9d922)

### AI Usage Disclosure

During the development of this project, AI was utilized as a learning tool and debugging assistant.  In particular, it was really helpful in

* **Explaining Docker fundamentals and how Docker Compose works,
* **Explaining what certain lines in Dockerfiles, configs, and scripts do,
* **Syntax and Configuration Troubleshooting:** Identifying mostly syntax errors in configuration files and scripts.

Note: Every line of code and configuration in this project was manually written by the author using various technical references. AI was used strictly as an explanatory and debugging assistant. All comments, structural decisions, and troubleshooting efforts (including isolating and narrowing down errors) were driven independently by the author.

---

## Project Description

### Directory structure
```
.
├── en.subject.pdf
├── Makefile
├── README.md
├── secrets
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── conf
        │   │   └── 50-server.cnf
        │   ├── Dockerfile
        │   └── tools
        │       └── mariadb.sh
        ├── nginx
        │   ├── conf
        │   │   └── nginx.conf
        │   ├── Dockerfile
        │   └── tools
        │       └── nginx.sh
        └── wordpress
            ├── conf
            │   └── www.conf
            ├── Dockerfile
            └── tools
                └── wordpress.sh

(secrets/* has to be created by the user of this repository)
```

### Main Design Choices

#### 1. Multi-Container Service Isolation (LEMP Stack)
Rather than packing Nginx, PHP-FPM, WordPress, and MariaDB into a single monolithic container, the architecture separates each service into its own dedicated container (`nginx`, `wordpress + PHP-FPM`, `mariadb`). 
* **Why:** This mirrors real-world microservice and containerization best practices, ensuring each container has a single responsibility, independent lifecycle management, and isolated resource utilization.

#### 2. Persistent Storage via Named Volumes
To satisfy data persistence requirements, Docker named volumes mapped to host directories (`/home/${USER}/data/mariadb` and `/home/${USER}/data/wordpress`) were used.  The first named volume is the MariaDB database where WordPress stores all its data (posts, profiles, usernames, passwords, etc.) and the second volume is used to store all the WordPress files.
* **Why:** This ensures that database records and WordPress files survive container teardowns, reboots, or updates without risking data loss.  Mapping them to host directories allows us to easily access the data and files from the host.

#### 3. Pragmatic Script Integration & Adaptation
During development, various deployment patterns and community guides were evaluated. A conscious choice was made to discard overly complex or bloated bootstrap scripts in favor of lean, readable shell scripts that execute health checks (like MariaDB `until` loops) before launching services.
* **Why:** Keeps the container boot sequence deterministic, transparent, and easy to debug during evaluation.

#### 4. Developer Experience & Workflow Automation (Makefile)
A custom `Makefile` was implemented to wrap complex Docker Compose commands (`docker compose up --build`, log streaming, pruning, and directory creation).
* **Why:** Reduces human error, speeds up common workflows, and ensures mandatory prerequisite directories (like `/home/${USER}/data/...`) are automatically set up before container initialization.

### Virtual Machines vs Docker
A container can almost be thought of as a mini virtual machine though it has key differences.  In particular, virtual machines each have their own OS installed on them each with its own kernel and they only share hardware with each other.  Containers on the other hand share a single linux kernel but may have different user spaces (package managers, system libraries, shell utilities, system architecture, etc.  Basically everything else that differentiates one linux distribution from another).  This way you could have a container for an app that only works on Ubuntu linux and another that works on Alpine linux on the same computer, for example.  Containers are therefore a lot lighter than a virtual machine in terms of size and startup time.

### Secrets vs Environment Variables
After deploying several Docker containers, you may find that each one of them requires concrete information such as passwords, usernames, domain names, file paths etc. in order to properly configure the services inside.  These values are usually passed in as environment variables.  You can pass these environment variables directly in docker-compose.yml or you can define them all in separate .env files.  However, it is good practice to keep sensitive values such as passwords or credentials in a separate `secrets` folder with each password in a separate file (e.g. `db_password.txt`, `db_root_password.txt`).  The `secrets` folder should always be ignored by Git to avoid pushing and thus revealing sensitive information to your public remote repository. 

In the docker-compose.yml file you can then declare each of these password files as secrets.  For each secret you provide its file path (e.g. `../secrets/db_password.txt`) so that Docker can automatically copy them to `/run/secrets/` inside each container that needs them.

### Docker Network vs Host Network


### Docker Volumes vs Bind Mounts
1. Bind mount: A file or directory in the host machine that is mounted to a container.  This file or directory can live anywhere on your host machine and any manual changes you make to it will be updated inside the container.  Good for changing source code that you want to run inside your container without having to rebuild the image.  These are good for development but they're NOT portable since their creation depends on your host's specific directory structure.

2. Named volume: A managed volume that is created and managed by Docker in its own specific folder in the host machine e.g. /var/lib/docker/volumes/... . It is managed via CLI commands (docker volume create, docker volume ls, etc.).  These are useful for storing data that needs to be shared between containers since they can be easily attached/detached.

In this project, we used named volumes mounted to host directories so that deleting the Docker volumes preserves the actual data on the host as an additional safety mechanism and for neat organization in docker-compose.yml (since they are named).


