COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data
WORDPRESS_DIR = $(DATA_DIR)/wordpress
MARIADB_DIR = $(DATA_DIR)/mariadb

all: build up

secrets:
	mkdir -p secrets
	touch secrets/db_password.txt
	touch secrets/db_root_password.txt
	touch secrets/wp_admin_password.txt
	touch secrets/wp_user_password.txt


logs:
	docker compose -f $(COMPOSE_FILE) logs

dirs:
	mkdir -p $(WORDPRESS_DIR)
	mkdir -p $(MARIADB_DIR)

cleandata:
	sudo rm -rf $(DATA_DIR)

build: dirs
	docker compose -f $(COMPOSE_FILE) build

up: dirs
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker system prune -af #deletes all unused images.  Not just dangling ones
	docker volume prune -f

fclean: clean cleandata

re: fclean all

.PHONY: all dirs cleandata secrets logs build up down clean fclean re
