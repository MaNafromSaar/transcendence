from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import httpx

app = FastAPI(title="AI wrapper")

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://ollama:11434")
TGI_URL = os.getenv("TGI_URL", "http://tgi:8080")
# Prefer Ollama if OLLAMA_URL is set (even if defaulted to ollama)
USE_OLLAMA = "ollama" in OLLAMA_URL.lower()


class GenerateReq(BaseModel):
    prompt: str
    max_tokens: int = 256
    model: str = "llama3.2:3b-instruct-q4_K_M"  # Default Ollama model


@app.get("/health")
async def health():
    backend = "ollama" if USE_OLLAMA else "tgi"
    backend_url = OLLAMA_URL if USE_OLLAMA else TGI_URL
    return {"status": "ok", "backend": backend, "backend_url": backend_url}


@app.post("/generate")
async def generate(req: GenerateReq):
    """
    Generate text using either Ollama or TGI backend.
    Ollama is preferred if OLLAMA_URL is set.
    """
    try:
        async with httpx.AsyncClient(timeout=120.0) as client:
            if USE_OLLAMA:
                # Ollama API format
                payload = {
                    "model": req.model,
                    "prompt": req.prompt,
                    "stream": False,
                    "options": {
                        "num_predict": req.max_tokens,
                        "temperature": 0.7
                    }
                }
                url = OLLAMA_URL.rstrip("/") + "/api/generate"
                r = await client.post(url, json=payload)
                if r.status_code == 200:
                    response = r.json()
                    # Ollama returns {"model":"...","response":"text here","done":true,...}
                    return {
                        "generated_text": response.get("response", ""),
                        "model": response.get("model", req.model),
                        "done": response.get("done", True)
                    }
                raise HTTPException(status_code=502, detail={
                    "backend": "ollama",
                    "status": r.status_code,
                    "body": r.text
                })
            else:
                # TGI API format (legacy)
                payload = {"inputs": req.prompt, "max_new_tokens": req.max_tokens}
                for path in ("/generate", "/v1/text-generation"):
                    url = TGI_URL.rstrip("/") + path
                    try:
                        r = await client.post(url, json=payload)
                        if r.status_code == 200:
                            return r.json()
                    except httpx.RequestError:
                        continue
                raise HTTPException(status_code=502, detail={
                    "backend": "tgi",
                    "error": "No TGI endpoint responded successfully"
                })
    except httpx.RequestError as e:
        raise HTTPException(status_code=503, detail={"error": str(e), "backend": "ollama" if USE_OLLAMA else "tgi"})
