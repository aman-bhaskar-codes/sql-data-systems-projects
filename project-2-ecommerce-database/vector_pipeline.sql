/* =====================================================
   VECTOR PIPELINE — PRODUCTION GRADE (PGVECTOR)
   ===================================================== */


/* =====================================================
   1. EXTENSION SETUP
   ===================================================== */

-- Must be run once per database
CREATE EXTENSION IF NOT EXISTS vector;


/* =====================================================
   2. EMBEDDING COLUMN (CLEAN + SAFE)
   ===================================================== */

-- Drop old incorrect types (array etc.)
ALTER TABLE products
DROP COLUMN IF EXISTS embedding;

-- Add correct vector column
-- 384 = fast + scalable (MiniLM class models)
ALTER TABLE products
ADD COLUMN embedding vector(384);


/* =====================================================
   3. INDEXING STRATEGY (CRITICAL)
   ===================================================== */

-- ⚡ IVFFLAT (default production choice)
CREATE INDEX IF NOT EXISTS idx_products_embedding_ivfflat
ON products
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- 🚀 Tune recall vs speed
-- Run before queries (session-level)
-- SET ivfflat.probes = 10;


/* =====================================================
   4. EMBEDDING POPULATION (SIMULATION)
   ===================================================== */

-- Simulate embeddings (for development only)
UPDATE products
SET embedding = (
    SELECT ARRAY(
        SELECT random()
        FROM generate_series(1,384)
    )::vector
);

-- ⚠️ Production:
-- Python / FastAPI → generate embeddings → insert


/* =====================================================
   5. CORE VECTOR SIMILARITY QUERY
   ===================================================== */

-- Find similar products to a given product
SELECT
    p2.product_id,
    p2.product_name,
    1 - (p1.embedding <-> p2.embedding) AS similarity_score
FROM products p1
JOIN products p2
    ON p1.product_id <> p2.product_id
WHERE p1.product_id = 100
ORDER BY p1.embedding <-> p2.embedding
LIMIT 10;


/* =====================================================
   6. HYBRID SEARCH (VECTOR + FULL-TEXT)
   ===================================================== */

-- ⚠️ IMPORTANT: normalize both scores

WITH query_embedding AS (
    SELECT embedding
    FROM products
    WHERE product_id = 100
)
SELECT
    p.product_id,
    p.product_name,

    -- cosine similarity (converted to similarity)
    1 - (p.embedding <-> q.embedding) AS vector_score,

    -- text relevance
    ts_rank(p.search_vector, to_tsquery('phone')) AS text_score,

    -- weighted hybrid score
    (
        0.7 * (1 - (p.embedding <-> q.embedding)) +
        0.3 * ts_rank(p.search_vector, to_tsquery('phone'))
    ) AS final_score

FROM products p, query_embedding q
WHERE p.search_vector @@ to_tsquery('phone')
ORDER BY final_score DESC
LIMIT 10;


/* =====================================================
   7. USER BEHAVIOR + VECTOR RECOMMENDATION
   ===================================================== */

-- Step 1: Get user's purchased products
WITH user_products AS (
    SELECT DISTINCT oi.product_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.user_id = 100
),

-- Step 2: Compute user taste embedding
user_embedding AS (
    SELECT AVG(p.embedding) AS embedding
    FROM products p
    WHERE p.product_id IN (SELECT product_id FROM user_products)
)

-- Step 3: Recommend similar products
SELECT
    p.product_id,
    p.product_name,
    1 - (p.embedding <-> ue.embedding) AS similarity
FROM products p, user_embedding ue
WHERE p.product_id NOT IN (SELECT product_id FROM user_products)
ORDER BY p.embedding <-> ue.embedding
LIMIT 10;


/* =====================================================
   8. FREQUENTLY BOUGHT + VECTOR HYBRID
   ===================================================== */

-- Combine collaborative + semantic signals

WITH co_purchase AS (
    SELECT
        oi1.product_id,
        oi2.product_id AS related_product,
        COUNT(*) AS freq
    FROM order_items oi1
    JOIN order_items oi2
        ON oi1.order_id = oi2.order_id
       AND oi1.product_id <> oi2.product_id
    GROUP BY oi1.product_id, oi2.product_id
),

target_embedding AS (
    SELECT embedding
    FROM products
    WHERE product_id = 100
)

SELECT
    p.product_id,
    p.product_name,
    cp.freq,

    1 - (p.embedding <-> te.embedding) AS vector_score,

    -- combined score
    (cp.freq * 0.5 + (1 - (p.embedding <-> te.embedding)) * 0.5) AS final_score

FROM co_purchase cp
JOIN products p ON p.product_id = cp.related_product
JOIN target_embedding te ON TRUE
WHERE cp.product_id = 100
ORDER BY final_score DESC
LIMIT 10;


/* =====================================================
   9. PERFORMANCE TUNING
   ===================================================== */

-- Tune recall dynamically
-- SET ivfflat.probes = 5;   -- faster
-- SET ivfflat.probes = 20;  -- more accurate


/* =====================================================
   10. OPTIONAL: HNSW INDEX (ADVANCED SYSTEMS)
   ===================================================== */

-- Uncomment if using HNSW instead of IVFFLAT
-- CREATE INDEX idx_products_embedding_hnsw
-- ON products
-- USING hnsw (embedding vector_cosine_ops);


/* =====================================================
   11. VECTOR CACHE (PRODUCTION OPTIMIZATION)
   ===================================================== */

CREATE TABLE IF NOT EXISTS vector_recommendations (
    user_id BIGINT,
    product_id BIGINT,
    similarity_score NUMERIC,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


/* =====================================================
   12. MATERIALIZED RECOMMENDATIONS (OPTIONAL)
   ===================================================== */

-- Precompute top recommendations (batch system)
-- Example (pseudo production pattern)

-- CREATE MATERIALIZED VIEW user_recommendations AS
-- SELECT ...


/* =====================================================
   END OF VECTOR PIPELINE
   ===================================================== */