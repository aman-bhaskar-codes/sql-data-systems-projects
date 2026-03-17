-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — AI & VECTOR QUERIES
-- ============================================================
-- pgvector-powered intelligence layer:
--   1. Vector similarity search
--   2. Hybrid search (semantic + keyword)
--   3. User-based recommendations
--   4. Collaborative + semantic hybrid recommendations
--   5. Performance tuning & validation
--
-- Requires: pgvector extension + vector(384) column populated
-- Run AFTER: seed.sql (which populates embeddings)
-- ============================================================


/* =====================================================
   SECTION 1 — VALIDATION & DIAGNOSTICS
   ===================================================== */

-- 1. Verify pgvector extension is installed
SELECT extname, extversion
FROM pg_extension
WHERE extname = 'vector';


-- 2. Check embedding coverage
SELECT
    COUNT(*) AS total_products,
    COUNT(embedding) AS with_embeddings,
    ROUND(COUNT(embedding)::NUMERIC / COUNT(*) * 100, 1) AS coverage_pct
FROM products;


-- 3. Verify distance calculation works
SELECT
    product_id,
    product_name,
    embedding <-> (SELECT embedding FROM products WHERE product_id = 1) AS distance
FROM products
WHERE product_id <> 1
ORDER BY distance
LIMIT 5;


/* =====================================================
   SECTION 2 — CORE VECTOR SIMILARITY
   ===================================================== */

-- 4. Find Similar Products (Cosine Distance)
-- Uses <-> operator for cosine distance (lower = more similar)
SELECT
    p2.product_id,
    p2.product_name,
    ROUND((1 - (p1.embedding <-> p2.embedding))::NUMERIC, 4) AS similarity_score
FROM products p1
JOIN products p2 ON p1.product_id <> p2.product_id
WHERE p1.product_id = 1
ORDER BY p1.embedding <-> p2.embedding
LIMIT 10;


-- 5. Find Products Similar to Multiple Products (Centroid)
-- Useful for "you might also like" based on a browsing session
WITH browsed_products AS (
    SELECT AVG(embedding) AS centroid
    FROM products
    WHERE product_id IN (1, 5, 10, 25)
)
SELECT
    p.product_id,
    p.product_name,
    ROUND((1 - (p.embedding <-> bp.centroid))::NUMERIC, 4) AS similarity
FROM products p, browsed_products bp
WHERE p.product_id NOT IN (1, 5, 10, 25)
ORDER BY p.embedding <-> bp.centroid
LIMIT 10;


/* =====================================================
   SECTION 3 — HYBRID SEARCH (SEMANTIC + KEYWORD)
   ===================================================== */

-- 6. Hybrid Search — Combine Vector + Full-Text
-- Weights: 70% semantic similarity, 30% keyword relevance
WITH query_embedding AS (
    SELECT embedding
    FROM products
    WHERE product_id = 100  -- In production: embedding of search query
)
SELECT
    p.product_id,
    p.product_name,
    ROUND((1 - (p.embedding <-> q.embedding))::NUMERIC, 4) AS vector_score,
    ROUND(ts_rank(p.search_vector, to_tsquery('phone'))::NUMERIC, 4) AS text_score,
    ROUND((
        0.7 * (1 - (p.embedding <-> q.embedding)) +
        0.3 * ts_rank(p.search_vector, to_tsquery('phone'))
    )::NUMERIC, 4) AS hybrid_score
FROM products p, query_embedding q
WHERE p.search_vector @@ to_tsquery('phone')
ORDER BY hybrid_score DESC
LIMIT 10;


/* =====================================================
   SECTION 4 — RECOMMENDATION ENGINE
   ===================================================== */

-- 7. User-Based Recommendation (Vector Taste Profile)
-- Computes user's "taste embedding" from purchase history,
-- then finds products closest to that taste.
WITH user_products AS (
    SELECT DISTINCT oi.product_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.user_id = 100
),
user_embedding AS (
    SELECT AVG(p.embedding) AS taste_vector
    FROM products p
    WHERE p.product_id IN (SELECT product_id FROM user_products)
)
SELECT
    p.product_id,
    p.product_name,
    ROUND((1 - (p.embedding <-> ue.taste_vector))::NUMERIC, 4) AS recommendation_score
FROM products p, user_embedding ue
WHERE p.product_id NOT IN (SELECT product_id FROM user_products)
ORDER BY p.embedding <-> ue.taste_vector
LIMIT 10;


-- 8. Hybrid Recommendation (Collaborative + Semantic)
-- Combines co-purchase frequency with vector similarity
-- for a balanced recommendation signal.
WITH co_purchase AS (
    SELECT
        oi1.product_id AS source_product,
        oi2.product_id AS related_product,
        COUNT(*) AS co_purchase_freq
    FROM order_items oi1
    JOIN order_items oi2
        ON oi1.order_id = oi2.order_id
       AND oi1.product_id <> oi2.product_id
    WHERE oi1.product_id = 1
    GROUP BY oi1.product_id, oi2.product_id
),
target_embedding AS (
    SELECT embedding FROM products WHERE product_id = 1
)
SELECT
    p.product_id,
    p.product_name,
    cp.co_purchase_freq,
    ROUND((1 - (p.embedding <-> te.embedding))::NUMERIC, 4) AS vector_score,
    ROUND((
        cp.co_purchase_freq * 0.5 +
        (1 - (p.embedding <-> te.embedding)) * 0.5
    )::NUMERIC, 4) AS hybrid_score
FROM co_purchase cp
JOIN products p ON p.product_id = cp.related_product
CROSS JOIN target_embedding te
ORDER BY hybrid_score DESC
LIMIT 10;


-- 9. Category-Aware Recommendations
-- Recommend products from a user's preferred categories
-- but semantically similar to their purchase history.
WITH user_categories AS (
    SELECT DISTINCT p.category_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.user_id = 100
),
user_taste AS (
    SELECT AVG(p.embedding) AS taste_vector
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.user_id = 100
)
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    ROUND((1 - (p.embedding <-> ut.taste_vector))::NUMERIC, 4) AS similarity
FROM products p
JOIN categories c ON p.category_id = c.category_id
CROSS JOIN user_taste ut
WHERE p.category_id IN (SELECT category_id FROM user_categories)
ORDER BY p.embedding <-> ut.taste_vector
LIMIT 10;


/* =====================================================
   SECTION 5 — PERFORMANCE TUNING
   ===================================================== */

-- 10. EXPLAIN ANALYZE — Verify Index Usage
EXPLAIN ANALYZE
SELECT product_id, product_name
FROM products
ORDER BY embedding <-> (SELECT embedding FROM products WHERE product_id = 1)
LIMIT 10;

-- Tuning IVFFLAT recall vs speed:
-- SET ivfflat.probes = 5;    -- Faster, less accurate
-- SET ivfflat.probes = 10;   -- Balanced (default recommendation)
-- SET ivfflat.probes = 20;   -- More accurate, slower

-- To force index usage (disable sequential scan):
-- SET enable_seqscan = OFF;

-- Alternative: HNSW index (better recall, more memory)
-- CREATE INDEX idx_products_embedding_hnsw
--     ON products USING hnsw (embedding vector_cosine_ops);