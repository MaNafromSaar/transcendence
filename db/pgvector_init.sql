-- pgvector initialization and documents table
-- Run this as the Postgres superuser (or via psql -U postgres -d $POSTGRES_DB)

CREATE EXTENSION IF NOT EXISTS vector;

-- Example table for storing document chunks and embeddings
CREATE TABLE IF NOT EXISTS documents (
  id BIGSERIAL PRIMARY KEY,
  doc_title TEXT,
  doc_text TEXT,
  embedding VECTOR(1536), -- adjust dimension to your embedding model
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ivfflat index for fast similarity search (choose lists based on dataset size)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'idx_documents_embedding'
  ) THEN
    EXECUTE 'CREATE INDEX idx_documents_embedding ON documents USING ivfflat (embedding) WITH (lists = 100)';
  END IF;
END$$;
