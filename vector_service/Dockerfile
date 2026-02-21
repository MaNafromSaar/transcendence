FROM python:3.12-slim

WORKDIR /app

# Install build deps required to compile psycopg2 if a prebuilt wheel isn't available
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	libpq-dev \
	&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Upgrade packaging tools first, then install requirements
RUN pip install --upgrade pip setuptools wheel && \
	pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV POSTGRES_HOST=db
ENV POSTGRES_DB=${POSTGRES_DB:-mydb}
ENV POSTGRES_USER=${POSTGRES_USER:-admin}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-secret}

EXPOSE 8081
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8081"]
