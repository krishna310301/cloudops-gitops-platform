FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /app
COPY src/ /app/src/

RUN adduser --disabled-password --gecos "" appuser
USER appuser

EXPOSE 8080
CMD ["python", "-m", "src.server"]
