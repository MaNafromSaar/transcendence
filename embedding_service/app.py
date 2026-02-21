from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os

app = FastAPI(title="embedding-service")

MODEL_NAME = os.getenv("MODEL_NAME", "sentence-transformers/all-MiniLM-L6-v2")

# lazy import to avoid heavy startup if not needed
_model = None

def get_model():
    global _model
    if _model is None:
        try:
            from sentence_transformers import SentenceTransformer
            _model = SentenceTransformer(MODEL_NAME)
        except Exception as e:
            raise RuntimeError(f"Failed to load model {MODEL_NAME}: {e}")
    return _model

class EmbedReq(BaseModel):
    texts: list[str]

class EmbedResp(BaseModel):
    embeddings: list[list[float]]

@app.get("/health")
def health():
    try:
        # attempt to load model metadata lazily
        if _model is None:
            return {"status": "ok", "model": MODEL_NAME, "loaded": False}
        else:
            return {"status": "ok", "model": MODEL_NAME, "loaded": True}
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))

@app.post("/embed", response_model=EmbedResp)
def embed(req: EmbedReq):
    try:
        model = get_model()
        embs = model.encode(req.texts, show_progress_bar=False)
        # ensure python lists
        embeddings = [list(map(float, e.tolist() if hasattr(e, 'tolist') else e)) for e in embs]
        return {"embeddings": embeddings}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
