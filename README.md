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

### References

* [Official Docker Documentation](https://docs.docker.com/)
* [Docker NGINX + WordPress + MariaDB Tutorial - Inception 42](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)
* [dperez-p's Inception Repository](https://github.com/dperez-p/Ring_05_Inception) - Included useful comments that helped me understand what each line in the Dockerfiles and scripts does.

### AI Usage Disclosure

During the development of this project, AI was utilized as a technical collaborator and debugging assistant.  In particular, it was really helpful in

* **Explaining how Docker and Docker Compose works,
* **Explaining what certain lines in Dockerfiles, configs, and scripts do,
* **Syntax and Configuration Troubleshooting:** Identifying syntax errors in configuration files and scripts.



