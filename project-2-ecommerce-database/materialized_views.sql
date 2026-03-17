-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — MATERIALIZED VIEWS
-- ============================================================
-- Pre-computed analytics views for fast dashboard queries.
-- Use REFRESH MATERIALIZED VIEW CONCURRENTLY for zero-downtime updates.
--
-- Run AFTER: seed.sql (requires populated data)
-- ============================================================


-- =====================================================
-- 1. SELLER REVENUE DASHBOARD
-- =====================================================
-- Pre-aggregates total revenue per seller for instant lookups.

CREATE MATERIALIZED VIEW mv_seller_revenue AS
SELECT
    s.seller_id,
    s.seller_name,
    COALESCE(SUM(oi.price * oi.quantity), 0) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM sellers s
LEFT JOIN products p ON s.seller_id = p.seller_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY s.seller_id, s.seller_name;

CREATE UNIQUE INDEX idx_mv_seller_revenue
    ON mv_seller_revenue(seller_id);


-- =====================================================
-- 2. PRODUCT STATISTICS
-- =====================================================
-- Combines sales, revenue, and average rating per product.

CREATE MATERIALIZED VIEW mv_product_stats AS
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(SUM(oi.price * oi.quantity), 0) AS total_revenue,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(DISTINCT r.review_id) AS review_count
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.category_id;

CREATE UNIQUE INDEX idx_mv_product_stats
    ON mv_product_stats(product_id);


-- =====================================================
-- 3. CATEGORY REVENUE BREAKDOWN
-- =====================================================
-- Revenue and order count aggregated per category.

CREATE MATERIALIZED VIEW mv_category_revenue AS
SELECT
    c.category_id,
    c.category_name,
    COALESCE(SUM(oi.price * oi.quantity), 0) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT p.product_id) AS product_count
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY c.category_id, c.category_name;

CREATE UNIQUE INDEX idx_mv_category_revenue
    ON mv_category_revenue(category_id);


-- =====================================================
-- 4. USER LIFETIME VALUE
-- =====================================================
-- Pre-computed LTV for customer segmentation.

CREATE MATERIALIZED VIEW mv_user_ltv AS
SELECT
    u.user_id,
    u.full_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_value,
    COALESCE(AVG(o.total_amount), 0) AS avg_order_value,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.full_name;

CREATE UNIQUE INDEX idx_mv_user_ltv
    ON mv_user_ltv(user_id);


-- =====================================================
-- REFRESH COMMANDS
-- =====================================================
-- Run these periodically (cron / pg_cron) to keep views fresh.
-- CONCURRENTLY requires the UNIQUE indexes created above.

-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_seller_revenue;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_product_stats;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_category_revenue;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_user_ltv;
