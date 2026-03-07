#!/bin/bash

set -e

echo "Applying schema..."

docker compose exec -T db psql \
  -U $POSTGRES_USER \
  -d $POSTGRES_DB \
  < seed/schema.sql

echo "Running seed script..."

python seed/seed.py

echo "Done."