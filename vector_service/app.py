from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import psycopg2
import psycopg2.extras
from typing import List, Optional

app = FastAPI(title="vector-search")

DB_HOST = os.getenv("POSTGRES_HOST", "db")
DB_NAME = os.getenv("POSTGRES_DB", "mydb")
DB_USER = os.getenv("POSTGRES_USER", "admin")
DB_PASS = os.getenv("POSTGRES_PASSWORD", "secret")


class InsertReq(BaseModel):
    doc_title: Optional[str]
    doc_text: str
    embedding: List[float]
    metadata: Optional[dict] = None


class SearchReq(BaseModel):
    embedding: List[float]
    k: int = 5


def get_conn():
    return psycopg2.connect(host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASS)


@app.get("/health")
def health():
    try:
        conn = get_conn()
        conn.close()
        return {"status": "ok"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))


@app.post("/insert")
def insert(req: InsertReq):
    vec = '[' + ','.join(map(str, req.embedding)) + ']'
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO documents (doc_title, doc_text, embedding, metadata) VALUES (%s, %s, %s::vector, %s) RETURNING id",
            (req.doc_title, req.doc_text, vec, psycopg2.extras.Json(req.metadata or {})),
        )
        doc_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return {"id": doc_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/search")
def search(req: SearchReq):
    vec = '[' + ','.join(map(str, req.embedding)) + ']'
    try:
        conn = get_conn()
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        sql = (
            "SELECT id, doc_title, doc_text, metadata, created_at, "
            "embedding FROM documents ORDER BY embedding <-> %s::vector LIMIT %s"
        )
        cur.execute(sql, (vec, req.k))
        rows = cur.fetchall()
        cur.close()
        conn.close()
        # convert embedding to list of floats before returning (psycopg returns memoryview)
        results = []
        for r in rows:
            emb = r.get('embedding')
            # embedding may be returned as list or memoryview; try to coerce
            if hasattr(emb, 'tolist'):
                emb_list = emb.tolist()
            else:
                try:
                    emb_list = list(emb)
                except Exception:
                    emb_list = None
            r['embedding'] = emb_list
            results.append(r)
        return {"results": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
