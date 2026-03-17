-- Enable pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- Ensure embedding column is correct type
-- ⚠️ Replace 1536 with your actual embedding dimension
ALTER TABLE products
ALTER COLUMN embedding TYPE vector(1536)
USING embedding::vector;

-- Optional but highly recommended (performance)
CREATE INDEX IF NOT EXISTS idx_products_embedding
ON products
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);