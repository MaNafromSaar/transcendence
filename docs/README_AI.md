# AI Service & RAG Integration — Quick Start

This folder contains a minimal FastAPI wrapper (`ai`) and a `docker-compose.ai.yml` fragment that exposes an internal HTTP endpoint for `n8n` to call:

- `/generate` — Accepts an object with `prompt` and `max_tokens`, forwarding the request to the configured TGI URL (default: `http://tgi:8080`).

## Design Choices
- The wrapper is intentionally minimal, providing a stable HTTP API for `n8n`. It forwards requests to TGI (if available) or can be extended to call a local `llama.cpp` binary.
- AI services are kept on the internal Docker network (`backend`) to ensure secure communication without public port exposure.

## Uploading a Model (Example: Mistral 7B GGUF)
1. **Create the models directory and set ownership** (run locally):

   ```bash
   mkdir -p ./models
   chmod 750 ./models
   ```

2. **Place the model file in the `models` directory**:

   ```bash
   cp /path/to/mistral-7b.gguf ./models/
   ```

3. **Configure TGI**:
   - Set `TGI_MODEL_ID` to the model you want to run.
   - Follow the TGI documentation to point it to the local model path.

   > **Note**: Running TGI with a large model may download additional artifacts.

## Starting Services
1. Ensure `docker-compose.ai.yml` and the `ai/` folder are in the project directory.
2. Start the services:

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.ai.yml up -d llama_wrapper
   ```

   > **Optional**: To start TGI (requires GPU or large resources):
   > ```bash
   > docker compose -f docker-compose.yml -f docker-compose.ai.yml up -d tgi llama_wrapper
   > ```

## Testing the Setup
Run the following command from the server or the `n8n` container:

```bash
curl -sS -X POST http://llama_wrapper:8080/generate -H 'Content-Type: application/json' \
  -d '{"prompt":"Say hello","max_tokens":20}' | jq .
```

## Notes & Next Steps
- **Local LLM Support**: For better local LLM support (e.g., `llama.cpp`), consider adding a containerized build that runs the binary and exposes a JSON HTTP endpoint. This requires building the binary and mounting the model files.
- **Embeddings**: Add a small embedding service (e.g., `sentence-transformers`) or use an external provider. Store vectors in `pgvector` (Postgres). Starter SQL migrations for `pgvector` can be added if needed.
