# Quick Reference Guide

## 🚀 Essential Commands

### Access Server
```bash
# SSH with tunnel (recommended)
ssh -L 5678:localhost:5678 -L 8087:localhost:8087 -L 3000:localhost:3000 deploy@localhost

# Simple SSH
ssh deploy@localhost
```

### Service URLs (via SSH tunnel)
- **n8n:** http://localhost:5678 (admin / <N8N_PASSWORD>)
- **Mistral API:** http://localhost:8087/generate
- **Metabase:** http://localhost:3000

---

## 📦 Docker Compose Quick Commands

```bash
cd ~/projects/Server

# View all services
docker compose ps

# Start everything
docker compose up -d

# Stop everything
docker compose stop

# Restart a service
docker compose restart llama_wrapper

# View logs
docker compose logs -f llama_wrapper

# Rebuild service
docker compose up -d --build llama_wrapper
```

---

## 🤖 Ollama Commands

```bash
# List models
docker compose exec ollama ollama list

# Pull model
docker compose exec ollama ollama pull mistral:7b-instruct-q4_0

# Interactive chat
docker compose exec ollama ollama run mistral:7b-instruct-q4_0

# Remove model
docker compose exec ollama ollama rm MODEL_NAME
```

---

## 🧪 API Testing

### Test Mistral
```bash
curl -X POST http://localhost:8087/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain AI in one sentence",
    "max_tokens": 50,
    "model": "mistral:7b-instruct-q4_0"
  }'
```

### Test Embeddings
```bash
curl -X POST http://localhost:8082/embed \
  -H "Content-Type: application/json" \
  -d '{"texts": ["Hello world"]}'
```

### Test Vector Search
```bash
curl -X POST http://localhost:8081/search \
  -H "Content-Type: application/json" \
  -d '{
    "query_embedding": [0.1, 0.2, ...],
    "top_k": 5
  }'
```

---

## 🔄 Sync Local → Server

```bash
# From local machine
rsync -avz --delete --progress \
  /home/mana/projects/Server/ \
  deploy@localhost:/home/deploy/projects/Server/

# Then rebuild on server
ssh deploy@localhost 'cd ~/projects/Server && docker compose up -d --build'
```

---

## 🗄️ Database

```bash
# Access PostgreSQL
docker compose exec db psql -U ${POSTGRES_USER} -d mydb

# Apply pgvector migration
docker compose cp db/pgvector_init.sql db:/tmp/
docker compose exec db psql -U ${POSTGRES_USER} -d mydb -f /tmp/pgvector_init.sql

# Backup
docker compose exec db pg_dump -U ${POSTGRES_USER} mydb > backup_$(date +%Y%m%d).sql

# Restore
cat backup.sql | docker compose exec -T db psql -U ${POSTGRES_USER} mydb
```

---

## 🛠️ Troubleshooting

### Service won't start
```bash
docker compose logs -f SERVICE_NAME
docker compose restart SERVICE_NAME
```

### Check resource usage
```bash
docker stats
free -h
df -h
```

### llama_wrapper returns errors
```bash
# Check backend status
curl http://localhost:8087/health

# View logs
docker compose logs llama_wrapper

# Restart
docker compose restart llama_wrapper
```

### Network issues between containers
```bash
# Check which containers are on network
docker network inspect server_backend

# Restart all services
docker compose down && docker compose up -d
```

---

## 📊 Service Status Check

```bash
# All services
docker compose ps

# Specific health
curl http://localhost:8087/health  # llama_wrapper
curl http://localhost:8082/health  # embedding_service
curl http://localhost:8081/health  # vector_service
```

---

## 🔐 Credentials

### n8n
- URL: http://localhost:5678
- User: `admin`
- Pass: `<N8N_PASSWORD>`

### Database
- Host: `db` (inside Docker) or `localhost:5432` (via tunnel)
- User: `${POSTGRES_USER}`
- Pass: `<POSTGRES_PASSWORD>`
- Database: `mydb`

### pgAdmin
- URL: http://localhost:8085 (if exposed)
- Email: `matthias.naumann@keepITlocal.ai`
- Pass: [from .env]

---

## 🎯 Common Tasks

### Add new Ollama model
```bash
docker compose exec ollama ollama pull gemma2:2b
# Test it
curl -X POST http://localhost:8087/generate \
  -d '{"prompt":"Test","max_tokens":20,"model":"gemma2:2b"}' \
  -H "Content-Type: application/json"
```

### Update a service
```bash
# Edit code locally
vim Server/ai/app.py

# Sync to server
rsync -avz /home/mana/projects/Server/ai/ deploy@localhost:/home/deploy/projects/Server/ai/

# Rebuild
ssh deploy@localhost 'cd ~/projects/Server && docker compose up -d --build llama_wrapper'
```

### Monitor logs in real-time
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f llama_wrapper ollama

# Last 50 lines
docker compose logs --tail=50 llama_wrapper
```

### Clean up Docker
```bash
# Remove stopped containers
docker compose down

# Remove unused images
docker image prune -a

# See disk usage
docker system df
```

---

## 📝 Model Recommendations

| Model | Size | Use Case | Speed | Quality |
|-------|------|----------|-------|---------|
| gemma2:2b | 1.6GB | Simple queries, fast responses | ⚡⚡⚡ | ⭐⭐ |
| mistral:7b-instruct-q4_0 | 4.1GB | General purpose, good balance | ⚡⚡ | ⭐⭐⭐ |
| llama3.1:8b-instruct-q4_0 | 4.7GB | Complex reasoning | ⚡⚡ | ⭐⭐⭐⭐ |
| mixtral:8x7b-instruct-q4_0 | 26GB | Advanced tasks (needs more RAM) | ⚡ | ⭐⭐⭐⭐⭐ |

---

## 🎨 n8n Workflow Tips

### HTTP Request to AI Services (from inside n8n)

**Use Docker hostnames:**
- ❌ `http://localhost:8087`
- ✅ `http://llama_wrapper:8080`
- ✅ `http://embedding_service:8082`
- ✅ `http://vector_service:8081`

### Example n8n HTTP Node for Mistral
- **Method:** POST
- **URL:** `http://llama_wrapper:8080/generate`
- **Body (JSON):**
```json
{
  "prompt": "{{$json["user_question"]}}",
  "max_tokens": 100,
  "model": "mistral:7b-instruct-q4_0"
}
```

---

## 🚨 Emergency Commands

### Everything is down
```bash
ssh deploy@localhost
cd ~/projects/Server
docker compose down
docker compose up -d
```

### Out of memory
```bash
# Check usage
free -h
docker stats

# Restart Ollama (frees memory)
docker compose restart ollama

# Stop non-critical services
docker compose stop metabase traefik proxy
```

### Can't connect via SSH tunnel
```bash
# Kill existing tunnel
pkill -f "ssh.*localhost"

# Reconnect
ssh -L 5678:localhost:5678 -L 8087:localhost:8087 -L 3000:localhost:3000 deploy@localhost
```

---

**See STACK_DOCUMENTATION.md for complete details.**
