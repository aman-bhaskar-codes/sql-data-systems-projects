-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — ANALYTICS ENGINE
-- ============================================================
-- 20 production-grade analytical queries across 6 complexity levels:
--   Level 1: Revenue Analytics
--   Level 2: Window Functions & Ranking
--   Level 3: Business Intelligence
--   Level 4: User Behavior Analysis
--   Level 5: Recommendation System
--   Level 6: Data Engineering
--
-- Run AFTER: seed.sql
-- ============================================================


/* =====================================================
   LEVEL 1 — REVENUE ANALYTICS
   ===================================================== */

-- 1. Top Revenue-Generating Products
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
    SUM(oi.quantity * oi.price) AS revenue,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;


-- 3. Monthly Revenue Trend
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(o.total_amount) AS revenue,
    COUNT(*) AS total_orders
FROM orders o
GROUP BY month
ORDER BY month;


/* =====================================================
   LEVEL 2 — WINDOW FUNCTIONS & RANKING
   ===================================================== */

-- 4. Rank Products by Revenue (Global)
SELECT
    product_id,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM (
    SELECT product_id, SUM(quantity * price) AS total_revenue
    FROM order_items
    GROUP BY product_id
) t
LIMIT 20;


-- 5. Top Product per Category (Partitioned Rank)
SELECT *
FROM (
    SELECT
        c.category_name,
        p.product_name,
        SUM(oi.quantity * oi.price) AS revenue,
        RANK() OVER (
            PARTITION BY c.category_name
            ORDER BY SUM(oi.quantity * oi.price) DESC
        ) AS category_rank
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_name, p.product_name
) ranked
WHERE category_rank = 1;


-- 6. Cumulative Revenue (Running Total)
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_amount) AS monthly_revenue,
    SUM(SUM(total_amount)) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS cumulative_revenue
FROM orders
GROUP BY month
ORDER BY month;


/* =====================================================
   LEVEL 3 — BUSINESS INTELLIGENCE
   ===================================================== */

-- 7. Customer Lifetime Value (CLV) — Top 20
SELECT
    u.user_id,
    u.full_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS lifetime_value,
    AVG(o.total_amount) AS avg_order_value
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.full_name
ORDER BY lifetime_value DESC
LIMIT 20;


-- 8. Average Order Value by Payment Method
SELECT
    p.payment_method,
    COUNT(*) AS payment_count,
    AVG(p.amount) AS avg_amount,
    SUM(p.amount) AS total_amount
FROM payments p
GROUP BY p.payment_method
ORDER BY total_amount DESC;


-- 9. Seller Performance Ranking
SELECT
    s.seller_id,
    s.seller_name,
    SUM(oi.quantity * oi.price) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders_fulfilled,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.price) DESC) AS rank
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON p.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_name
LIMIT 20;


/* =====================================================
   LEVEL 4 — USER BEHAVIOR ANALYSIS
   ===================================================== */

-- 10. Most Active Users (Event-Based)
SELECT
    user_id,
    COUNT(*) AS activity_count,
    COUNT(DISTINCT event_type) AS event_types
FROM system_events
GROUP BY user_id
ORDER BY activity_count DESC
LIMIT 10;


-- 11. Conversion Funnel (Views → Cart → Purchase)
SELECT
    COUNT(*) FILTER (WHERE event_type = 'view') AS views,
    COUNT(*) FILTER (WHERE event_type = 'cart') AS carts,
    COUNT(*) FILTER (WHERE event_type = 'purchase') AS purchases,
    ROUND(
        COUNT(*) FILTER (WHERE event_type = 'purchase')::NUMERIC /
        NULLIF(COUNT(*) FILTER (WHERE event_type = 'view'), 0) * 100, 2
    ) AS conversion_rate_pct
FROM system_events;


-- 12. Repeat Buyers (Customers with 2+ orders)
SELECT
    user_id,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY user_id
HAVING COUNT(order_id) > 1
ORDER BY total_orders DESC
LIMIT 20;


-- 13. Cart Abandonment Analysis
SELECT
    COUNT(DISTINCT c.cart_id) AS total_carts,
    COUNT(DISTINCT CASE WHEN o.order_id IS NULL THEN c.cart_id END) AS abandoned_carts,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_id IS NULL THEN c.cart_id END)::NUMERIC /
        NULLIF(COUNT(DISTINCT c.cart_id), 0) * 100, 2
    ) AS abandonment_rate_pct
FROM carts c
LEFT JOIN orders o ON c.user_id = o.user_id;


/* =====================================================
   LEVEL 5 — RECOMMENDATION SYSTEM
   ===================================================== */

-- 14. Frequently Bought Together
SELECT
    oi1.product_id AS product_1,
    oi2.product_id AS product_2,
    COUNT(*) AS frequency
FROM order_items oi1
JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id < oi2.product_id
GROUP BY oi1.product_id, oi2.product_id
ORDER BY frequency DESC
LIMIT 20;


-- 15. Personalized Recommendations (Collaborative Filtering)
-- "Users who bought X also bought Y"
SELECT
    oi2.product_id AS recommended_product,
    COUNT(*) AS relevance_score
FROM order_items oi1
JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id <> oi2.product_id
WHERE oi1.product_id IN (
    SELECT product_id FROM order_items
    WHERE order_id IN (SELECT order_id FROM orders WHERE user_id = 100)
)
GROUP BY oi2.product_id
ORDER BY relevance_score DESC
LIMIT 10;


-- 16. Trending Products (Last 7 Days)
SELECT
    oi.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY oi.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 10;


/* =====================================================
   LEVEL 6 — DATA ENGINEERING
   ===================================================== */

-- 17. Top 3 Products per Seller (ROW_NUMBER)
SELECT *
FROM (
    SELECT
        s.seller_name,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        ROW_NUMBER() OVER (
            PARTITION BY s.seller_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS rank
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN sellers s ON p.seller_id = s.seller_id
    GROUP BY s.seller_id, s.seller_name, p.product_name
) ranked
WHERE rank <= 3;


-- 18. Revenue Contribution Percentage (Global Share)
SELECT
    product_id,
    SUM(quantity * price) AS revenue,
    ROUND(
        SUM(quantity * price) * 100.0 /
        SUM(SUM(quantity * price)) OVER (), 4
    ) AS revenue_share_pct
FROM order_items
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 20;


-- 19. Full-Text Product Search
SELECT
    product_id,
    product_name,
    ts_rank(search_vector, to_tsquery('phone & smart')) AS relevance
FROM products
WHERE search_vector @@ to_tsquery('phone & smart')
ORDER BY relevance DESC
LIMIT 10;


-- 20. JSONB Metadata Query — Filter by Brand
SELECT
    p.product_id,
    p.product_name,
    pm.metadata->>'brand' AS brand,
    pm.metadata->>'color' AS color
FROM product_metadata pm
JOIN products p ON pm.product_id = p.product_id
WHERE pm.metadata @> '{"brand": "Brand 5"}'
LIMIT 10;