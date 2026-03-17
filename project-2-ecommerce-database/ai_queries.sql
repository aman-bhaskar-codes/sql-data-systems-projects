/* =====================================================
   AI + VECTOR QUERIES + VALIDATION (FIXED)
   ===================================================== */


/* =====================================================
   SECTION 1 — VALIDATION
   ===================================================== */

-- 1. Check pgvector
SELECT extname
FROM pg_extension
WHERE extname = 'vector';


-- 2. Check embeddings
SELECT
    product_id,
    embedding IS NOT NULL AS has_embedding
FROM products
LIMIT 5;


-- 3. Distance check
SELECT
    product_id,
    embedding <-> (
        SELECT embedding FROM products WHERE product_id = 1
    ) AS distance
FROM products
ORDER BY distance
LIMIT 5;


-- 4. Similarity (FIXED ROUND)
SELECT
    p2.product_id,
    p2.product_name,
    ROUND((1 - (p1.embedding <-> p2.embedding))::numeric, 4) AS similarity
FROM products p1
JOIN products p2
    ON p1.product_id <> p2.product_id
WHERE p1.product_id = 1
ORDER BY similarity DESC
LIMIT 5;


/* =====================================================
   SECTION 2 — PERFORMANCE
   ===================================================== */

EXPLAIN ANALYZE
SELECT product_id
FROM products
ORDER BY embedding <-> (
    SELECT embedding FROM products WHERE product_id = 1
)
LIMIT 10;

-- SET enable_seqscan = OFF;


/* =====================================================
   SECTION 3 — CORE AI
   ===================================================== */

-- 5. Similar Products
SELECT
    p2.product_id,
    p2.product_name,
    ROUND((1 - (p1.embedding <-> p2.embedding))::numeric, 4) AS similarity
FROM products p1
JOIN products p2
    ON p1.product_id <> p2.product_id
WHERE p1.product_id = 1
ORDER BY similarity DESC
LIMIT 10;


-- 6. Hybrid Search (FIXED)
SELECT
    product_name,
    ROUND(ts_rank(search_vector, to_tsquery('phone'))::numeric, 3) AS text_score,
    ROUND((1 - (
        embedding <-> (
            SELECT embedding FROM products WHERE product_id = 1
        )
    ))::numeric, 3) AS vector_score
FROM products
WHERE search_vector @@ to_tsquery('phone')
ORDER BY vector_score DESC
LIMIT 10;


/* =====================================================
   SECTION 4 — RECOMMENDATION
   ===================================================== */

-- 7. User-Based Recommendation
SELECT
    product_id,
    product_name
FROM products
ORDER BY embedding <-> (
    SELECT AVG(embedding)
    FROM products
    WHERE product_id IN (
        SELECT product_id
        FROM order_items
        WHERE order_id IN (
            SELECT order_id
            FROM orders
            WHERE user_id = 10
        )
    )
)
LIMIT 10;


-- 8. Hybrid Recommendation (FIXED)
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
    WHERE product_id = 1
)
SELECT
    p.product_id,
    p.product_name,
    cp.freq,
    ROUND((1 - (p.embedding <-> te.embedding))::numeric, 3) AS vector_score,
    ROUND((
        cp.freq * 0.5 +
        (1 - (p.embedding <-> te.embedding)) * 0.5
    )::numeric, 3) AS final_score
FROM co_purchase cp
JOIN products p ON p.product_id = cp.related_product
JOIN target_embedding te ON TRUE
WHERE cp.product_id = 1
ORDER BY final_score DESC
LIMIT 10;


/* =====================================================
   END
   ===================================================== */