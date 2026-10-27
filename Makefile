COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data
WORDPRESS_DIR = $(DATA_DIR)/wordpress
MARIADB_DIR = $(DATA_DIR)/mariadb

all: up #include 'build' later

wordpress_dir:
	mkdir -p $(WORDPRESS_DIR)

mariadb_dir:
	mkdir -p $(MARIADB_DIR)

#build: wordpress_dir mariadb_dir
#	docker compose -f $(COMPOSE_FILE) build

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker system prune -af #deletes all unused images.  Not just dangling ones

fclean: clean
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all wordpress_dir mariadb_dir up down clean fclean re
