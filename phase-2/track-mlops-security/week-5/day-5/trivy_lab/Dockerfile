# use buster contains many vuln
FROM python:3.11-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

RUN chown -R appuser:appgroup /app

USER appuser
# run in admin mode (misconfiguration)
CMD ["python", "-m", "http.server", "8000"]
