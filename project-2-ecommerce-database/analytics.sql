/* =====================================================
   E-COMMERCE ANALYTICS ENGINE
   Production-Level SQL (ERROR-SAFE FINAL)
   ===================================================== */


/* =====================================================
   LEVEL 1 — ADVANCED ANALYTICS
   ===================================================== */

-- 1. Top Revenue Generating Products
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 10;


-- 2. Revenue by Category
SELECT
    c.category_name,
    SUM(oi.quantity * oi.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;


-- 3. Monthly Revenue Trend
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(o.total_amount) AS revenue
FROM orders o
GROUP BY month
ORDER BY month;


/* =====================================================
   LEVEL 2 — WINDOW FUNCTIONS & RANKING
   ===================================================== */

-- 4. Rank Products by Revenue
SELECT
    product_id,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS rank
FROM (
    SELECT
        product_id,
        SUM(quantity * price) AS total_revenue
    FROM order_items
    GROUP BY product_id
) t;


-- 5. Top Product per Category
SELECT *
FROM (
    SELECT
        c.category_name,
        p.product_name,
        SUM(oi.quantity * oi.price) AS revenue,
        RANK() OVER (
            PARTITION BY c.category_name
            ORDER BY SUM(oi.quantity * oi.price) DESC
        ) AS rnk
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_name, p.product_name
) t
WHERE rnk = 1;


-- 6. Running Revenue (Cumulative)
SELECT
    order_date,
    SUM(total_amount) OVER (ORDER BY order_date) AS cumulative_revenue
FROM orders;


/* =====================================================
   LEVEL 3 — BUSINESS INTELLIGENCE
   ===================================================== */

-- 7. Customer Lifetime Value (CLV)
SELECT
    user_id,
    SUM(total_amount) AS lifetime_value
FROM orders
GROUP BY user_id
ORDER BY lifetime_value DESC;


-- 8. Average Order Value per User
SELECT
    user_id,
    AVG(total_amount) AS avg_order_value
FROM orders
GROUP BY user_id;


-- 9. Seller Performance Ranking
SELECT
    p.seller_id,
    SUM(oi.quantity * oi.price) AS revenue,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.price) DESC) AS rank
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.seller_id;


/* =====================================================
   LEVEL 4 — USER BEHAVIOR ANALYSIS
   ===================================================== */

-- 10. Most Active Users
SELECT
    user_id,
    COUNT(*) AS activity_count
FROM system_events
GROUP BY user_id
ORDER BY activity_count DESC
LIMIT 10;


-- 11. Conversion Funnel
SELECT
    COUNT(*) FILTER (WHERE event_type = 'view') AS views,
    COUNT(*) FILTER (WHERE event_type = 'cart') AS carts,
    COUNT(*) FILTER (WHERE event_type = 'purchase') AS purchases
FROM system_events;


-- 12. Repeat Buyers
SELECT
    user_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY user_id
HAVING COUNT(order_id) > 1;


/* =====================================================
   LEVEL 5 — RECOMMENDATION SYSTEM
   ===================================================== */

-- 13. Frequently Bought Together
SELECT
    oi1.product_id AS product_1,
    oi2.product_id AS product_2,
    COUNT(*) AS frequency
FROM order_items oi1
JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id <> oi2.product_id
GROUP BY oi1.product_id, oi2.product_id
ORDER BY frequency DESC
LIMIT 20;


-- 14. Personalized Recommendations
SELECT
    p.product_id,
    p.product_name,
    COUNT(*) AS relevance
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.user_id = 100
GROUP BY p.product_id, p.product_name
ORDER BY relevance DESC
LIMIT 10;


-- 15. Trending Products
SELECT
    oi.product_id,
    SUM(oi.quantity) AS sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY oi.product_id
ORDER BY sales DESC
LIMIT 10;


/* =====================================================
   LEVEL 6 — AI + VECTOR QUERIES (ERROR-SAFE)
   ===================================================== */

-- 16. Similar Products (WORKS WITH ARRAYS ✅)
SELECT
    p1.product_id,
    p1.product_name,
    (
        SUM(a.val * b.val) /
        (SQRT(SUM(a.val * a.val)) * SQRT(SUM(b.val * b.val)))
    ) AS similarity
FROM products p1
JOIN products p2 ON p2.product_id = 10
JOIN LATERAL UNNEST(p1.embedding) WITH ORDINALITY AS a(val, i) ON TRUE
JOIN LATERAL UNNEST(p2.embedding) WITH ORDINALITY AS b(val, j)
    ON a.i = b.j
GROUP BY p1.product_id, p1.product_name
ORDER BY similarity DESC
LIMIT 10;


-- ✅ WHEN YOU CONVERT TO pgvector, REPLACE ABOVE WITH:
-- ORDER BY p1.embedding <-> p2.embedding


-- 17. Most Similar Users
SELECT
    user_id,
    COUNT(*) AS similarity_score
FROM system_events
WHERE event_type = 'purchase'
GROUP BY user_id
ORDER BY similarity_score DESC
LIMIT 10;


-- 18. Semantic Search
SELECT
    product_id,
    product_name
FROM products
WHERE search_vector @@ to_tsquery('phone & smart');


/* =====================================================
   BONUS — INTERVIEW LEVEL
   ===================================================== */

-- 19. Top 3 Products per Seller
SELECT *
FROM (
    SELECT
        p.seller_id,
        p.product_name,
        SUM(oi.quantity) AS sales,
        ROW_NUMBER() OVER (
            PARTITION BY p.seller_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS rank
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.seller_id, p.product_name
) t
WHERE rank <= 3;


/* =====================================================
   ULTRA — DATA ENGINEERING LEVEL
   ===================================================== */

-- 20. Revenue Contribution %
SELECT
    product_id,
    SUM(quantity * price) AS revenue,
    SUM(quantity * price) * 100.0 /
    SUM(SUM(quantity * price)) OVER () AS revenue_percentage
FROM order_items
GROUP BY product_id
ORDER BY revenue DESC;