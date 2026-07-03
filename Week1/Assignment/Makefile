.PHONY: cert up down logs psql seed clean

cert:
	mkdir -p nginx/certs
	openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
		-keyout nginx/certs/key.pem -out nginx/certs/cert.pem \
		-subj "/CN=localhost"

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

psql:
	docker compose exec db psql -U $$(grep POSTGRES_USER .env | cut -d '=' -f2) -d $$(grep POSTGRES_DB .env | cut -d '=' -f2)

seed:
	@echo "Du lieu ban dau da duoc nap tu dong qua kich ban SQL khi khoi dong"

clean:
	docker compose down -v
	rm -rf nginx/certs