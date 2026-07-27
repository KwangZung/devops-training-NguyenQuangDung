# use buster contains many vuln
FROM python:3.7-buster
WORKDIR /app

# run in admin mode (misconfiguration)
CMD ["python", "-m", "http.server", "8000"]
