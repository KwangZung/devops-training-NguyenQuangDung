.PHONY: cert

cert:
	mkdir -p nginx/certs
	openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
		-keyout nginx/certs/key.pem -out nginx/certs/cert.pem \
		-subj "/CN=localhost"