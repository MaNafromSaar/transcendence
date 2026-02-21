from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="mock-ai-model", version="0.1")


class PredictRequest(BaseModel):
    input: str
    mode: str = "echo"  # modes: echo, reverse, mock


class PredictResponse(BaseModel):
    output: str
    model: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
def predict(req: PredictRequest):
    text = req.input or ""
    if req.mode == "reverse":
        out = text[::-1]
    elif req.mode == "mock":
        # simple mock 'AI' behaviour: uppercase and length
        out = f"MOCK({text.upper()[:200]}) len={len(text)}"
    else:
        out = text
    return PredictResponse(output=out, model="mock-v1")


@app.get("/metadata")
def metadata():
    return {"name": "mock-v1", "type": "text", "capabilities": ["echo","reverse","mock"]}
