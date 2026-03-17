.PHONY: up down logs ps shell backup

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f postgres

ps:
	docker compose ps

shell:
	docker compose exec postgres psql -U $$(grep DB_USER .env | cut -d= -f2) -d contentgen

backup:
	bash scripts/backup.sh
