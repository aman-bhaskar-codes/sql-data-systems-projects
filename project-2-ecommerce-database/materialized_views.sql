-- =====================================================
-- MATERIALIZED VIEW (FIXED)
-- =====================================================

-- Step 1: Create view
CREATE MATERIALIZED VIEW seller_revenue AS
SELECT
p.seller_id,
SUM(oi.price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.seller_id;

-- Step 2: Create UNIQUE index (REQUIRED for CONCURRENTLY)
CREATE UNIQUE INDEX idx_seller_revenue_unique
ON seller_revenue(seller_id);

-- Step 3: Now concurrent refresh works
REFRESH MATERIALIZED VIEW CONCURRENTLY seller_revenue;
