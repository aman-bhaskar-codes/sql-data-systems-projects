-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — DATA SEEDING
-- ============================================================
-- Generates ~15M+ synthetic rows across all tables.
-- Uses generate_series(), RANDOM(), JSONB, and vector simulation.
--
-- Run AFTER: schema.sql, indexes.sql (or partitions.sql if using partitions)
-- ⏱️  Execution time: several minutes due to dataset scale.
-- ============================================================


-- =====================================================
-- 1. CATEGORIES (100 records)
-- =====================================================

INSERT INTO categories (category_name)
SELECT 'Category ' || gs
FROM generate_series(1, 100) gs;


-- =====================================================
-- 2. USERS (1,000,000 records)
-- =====================================================

INSERT INTO users (full_name, email, phone)
SELECT
    'User ' || gs,
    'user' || gs || '@mail.com',
    (9000000000 + gs)::TEXT
FROM generate_series(1, 1000000) gs;


-- =====================================================
-- 3. USER ADDRESSES (1M records — one per user)
-- =====================================================

INSERT INTO user_addresses (user_id, street, city, state)
SELECT
    user_id,
    'Street ' || user_id,
    'City ' || (RANDOM() * 20)::INT,
    'State ' || (RANDOM() * 10)::INT
FROM users;


-- =====================================================
-- 4. USER SESSIONS (~400K records)
-- =====================================================

INSERT INTO user_sessions (user_id, logout_time)
SELECT
    user_id,
    CURRENT_TIMESTAMP + ((RANDOM() * 120)::INT * INTERVAL '1 minute')
FROM users
WHERE RANDOM() < 0.4;


-- =====================================================
-- 5. SELLERS (2,000 records)
-- =====================================================

INSERT INTO sellers (seller_name, email, rating)
SELECT
    'Seller ' || gs,
    'seller' || gs || '@shop.com',
    ROUND((RANDOM() * 4 + 1)::NUMERIC, 2)  -- Rating 1.00–5.00
FROM generate_series(1, 2000) gs;

INSERT INTO seller_addresses (seller_id, street, city, state)
SELECT
    seller_id,
    'Street ' || seller_id,
    'City ' || (RANDOM() * 20)::INT,
    'State ' || (RANDOM() * 10)::INT
FROM sellers;


-- =====================================================
-- 6. PRODUCTS (200,000 records)
-- =====================================================

INSERT INTO products (seller_id, category_id, product_name, price, description)
SELECT
    (RANDOM() * 1999 + 1)::INT,
    (RANDOM() * 99 + 1)::INT,
    'Product ' || gs,
    ROUND((RANDOM() * 990 + 10)::NUMERIC, 2),  -- Price ₹10–₹1000
    'High-quality product ' || gs || ' with premium features'
FROM generate_series(1, 200000) gs;

-- Product images (one per product)
INSERT INTO product_images (product_id, image_url)
SELECT product_id, 'https://img.store.com/products/' || product_id || '.jpg'
FROM products;

-- Product attributes (~100K, 50% of products)
INSERT INTO product_attributes (product_id, attribute_name, attribute_value)
SELECT
    product_id, 'color',
    CASE
        WHEN RANDOM() < 0.25 THEN 'red'
        WHEN RANDOM() < 0.50 THEN 'blue'
        WHEN RANDOM() < 0.75 THEN 'black'
        ELSE 'white'
    END
FROM products
WHERE RANDOM() < 0.5;

-- Product tags (~80K, 40% of products)
INSERT INTO product_tags (product_id, tag_name)
SELECT
    product_id,
    CASE
        WHEN RANDOM() < 0.3 THEN 'popular'
        WHEN RANDOM() < 0.6 THEN 'sale'
        ELSE 'new-arrival'
    END
FROM products
WHERE RANDOM() < 0.4;

-- Product metadata (JSONB — all products)
INSERT INTO product_metadata (product_id, metadata)
SELECT
    product_id,
    jsonb_build_object(
        'brand', 'Brand ' || (RANDOM() * 50)::INT,
        'color', CASE WHEN RANDOM() < 0.5 THEN 'red' ELSE 'blue' END,
        'weight_kg', ROUND((RANDOM() * 10)::NUMERIC, 1),
        'warranty_months', (RANDOM() * 24)::INT
    )
FROM products;


-- =====================================================
-- 7. WAREHOUSES + INVENTORY (200K records)
-- =====================================================

INSERT INTO warehouses (warehouse_name, city, state)
SELECT 'Warehouse ' || gs, 'City ' || gs, 'State ' || (gs % 10)
FROM generate_series(1, 20) gs;

INSERT INTO inventory (product_id, warehouse_id, stock_quantity)
SELECT
    product_id,
    (RANDOM() * 19 + 1)::INT,
    (RANDOM() * 500)::INT
FROM products;

-- Inventory movements (1M records)
INSERT INTO inventory_movements (product_id, warehouse_id, quantity_change, movement_type)
SELECT
    (RANDOM() * 199999 + 1)::INT,
    (RANDOM() * 19 + 1)::INT,
    (RANDOM() * 50)::INT,
    CASE WHEN RANDOM() < 0.5 THEN 'restock' ELSE 'sale' END
FROM generate_series(1, 1000000);


-- =====================================================
-- 8. CARTS + ITEMS (~600K records)
-- =====================================================

INSERT INTO carts (user_id)
SELECT user_id FROM users WHERE RANDOM() < 0.6;

INSERT INTO cart_items (cart_id, product_id, quantity)
SELECT
    cart_id,
    (RANDOM() * 199999 + 1)::INT,
    (RANDOM() * 4 + 1)::INT
FROM carts;


-- =====================================================
-- 9. ORDERS (2,000,000 records)
-- =====================================================

INSERT INTO orders (user_id, total_amount, order_status, order_date)
SELECT
    (RANDOM() * 999999 + 1)::INT,
    ROUND((RANDOM() * 2000 + 50)::NUMERIC, 2),
    (CASE
        WHEN RANDOM() < 0.2 THEN 'pending'
        WHEN RANDOM() < 0.4 THEN 'confirmed'
        WHEN RANDOM() < 0.7 THEN 'shipped'
        ELSE 'delivered'
    END)::order_status_enum,
    TIMESTAMP '2024-01-01' + (RANDOM() * 730)::INT * INTERVAL '1 day'
FROM generate_series(1, 2000000);

-- Order items (5M records)
INSERT INTO order_items (order_id, order_date, product_id, quantity, price)
SELECT
    o.order_id,
    o.order_date,
    (RANDOM() * 199999 + 1)::INT,
    (RANDOM() * 3 + 1)::INT,
    ROUND((RANDOM() * 990 + 10)::NUMERIC, 2)
FROM orders o
CROSS JOIN generate_series(1, 3) gs
WHERE RANDOM() < 0.85;


-- =====================================================
-- 10. PAYMENTS (2M records — one per order)
-- =====================================================

INSERT INTO payments (order_id, order_date, payment_method, payment_status, amount)
SELECT
    order_id, order_date,
    CASE
        WHEN RANDOM() < 0.4 THEN 'card'
        WHEN RANDOM() < 0.7 THEN 'upi'
        WHEN RANDOM() < 0.9 THEN 'wallet'
        ELSE 'net_banking'
    END,
    'completed'::payment_status_enum,
    total_amount
FROM orders;

-- Refunds (~5% of payments)
INSERT INTO refunds (payment_id, refund_amount, refund_reason)
SELECT
    payment_id, amount,
    CASE
        WHEN RANDOM() < 0.5 THEN 'customer request'
        ELSE 'defective product'
    END
FROM payments
WHERE RANDOM() < 0.05;


-- =====================================================
-- 11. SHIPMENTS (2M records)
-- =====================================================

INSERT INTO shipments (order_id, order_date, warehouse_id, shipment_status)
SELECT
    order_id, order_date,
    (RANDOM() * 19 + 1)::INT,
    (CASE
        WHEN RANDOM() < 0.3 THEN 'processing'
        WHEN RANDOM() < 0.6 THEN 'shipped'
        WHEN RANDOM() < 0.8 THEN 'in_transit'
        ELSE 'delivered'
    END)::shipment_status_enum
FROM orders;

INSERT INTO shipment_tracking (shipment_id, status, location)
SELECT
    shipment_id,
    CASE
        WHEN RANDOM() < 0.3 THEN 'processing'
        WHEN RANDOM() < 0.6 THEN 'in_transit'
        ELSE 'delivered'
    END,
    'City ' || (RANDOM() * 20)::INT
FROM shipments;


-- =====================================================
-- 12. REVIEWS (500K records)
-- =====================================================

INSERT INTO reviews (user_id, product_id, rating, review_text)
SELECT
    (RANDOM() * 999999 + 1)::INT,
    (RANDOM() * 199999 + 1)::INT,
    FLOOR(RANDOM() * 5 + 1)::INT,
    CASE
        WHEN RANDOM() < 0.3 THEN 'Excellent quality, highly recommend!'
        WHEN RANDOM() < 0.6 THEN 'Good product, fast delivery.'
        WHEN RANDOM() < 0.8 THEN 'Average product, could be better.'
        ELSE 'Not satisfied with the quality.'
    END
FROM generate_series(1, 500000);

INSERT INTO review_votes (review_id, user_id, vote_type)
SELECT
    (RANDOM() * 499999 + 1)::INT,
    (RANDOM() * 999999 + 1)::INT,
    CASE WHEN RANDOM() < 0.7 THEN 'helpful' ELSE 'not_helpful' END
FROM generate_series(1, 800000);


-- =====================================================
-- 13. ANALYTICS DATA (~5M records)
-- =====================================================

-- Product views (3M)
INSERT INTO product_views (user_id, product_id)
SELECT (RANDOM() * 999999 + 1)::INT, (RANDOM() * 199999 + 1)::INT
FROM generate_series(1, 3000000);

-- Search logs (2M)
INSERT INTO search_logs (user_id, search_query)
SELECT
    (RANDOM() * 999999 + 1)::INT,
    CASE
        WHEN RANDOM() < 0.2 THEN 'phone'
        WHEN RANDOM() < 0.4 THEN 'laptop'
        WHEN RANDOM() < 0.6 THEN 'headphones'
        WHEN RANDOM() < 0.8 THEN 'camera'
        ELSE 'tablet'
    END
FROM generate_series(1, 2000000);

-- System events (2M)
INSERT INTO system_events (user_id, event_type, event_data, event_time)
SELECT
    (RANDOM() * 999999 + 1)::INT,
    CASE
        WHEN RANDOM() < 0.5 THEN 'view'
        WHEN RANDOM() < 0.8 THEN 'cart'
        ELSE 'purchase'
    END,
    jsonb_build_object('product_id', (RANDOM() * 199999 + 1)::INT),
    TIMESTAMP '2024-01-01' + (RANDOM() * 730)::INT * INTERVAL '1 day'
FROM generate_series(1, 2000000);


-- =====================================================
-- 14. AI / FEATURE STORE DATA
-- =====================================================

-- User features
INSERT INTO user_features (user_id, total_orders, total_spent, avg_order_value, favorite_category)
SELECT
    user_id,
    (RANDOM() * 50)::INT,
    ROUND((RANDOM() * 50000)::NUMERIC, 2),
    ROUND((RANDOM() * 2000)::NUMERIC, 2),
    (RANDOM() * 99 + 1)::INT
FROM users;

-- Product features
INSERT INTO product_features (product_id, popularity_score, avg_rating, total_sales)
SELECT
    product_id,
    ROUND((RANDOM() * 100)::NUMERIC, 2),
    ROUND((RANDOM() * 4 + 1)::NUMERIC, 2),
    (RANDOM() * 10000)::INT
FROM products;

-- Product relationships (500K co-purchase pairs)
INSERT INTO product_relationships (product_a, product_b, relation_type)
SELECT
    (RANDOM() * 199999 + 1)::INT,
    (RANDOM() * 199999 + 1)::INT,
    CASE WHEN RANDOM() < 0.7 THEN 'frequently_bought' ELSE 'similar' END
FROM generate_series(1, 500000);

-- Daily product metrics (200K)
INSERT INTO product_metrics_daily (product_id, views, purchases, revenue, metric_date)
SELECT
    product_id,
    (RANDOM() * 1000)::INT,
    (RANDOM() * 200)::INT,
    ROUND((RANDOM() * 10000)::NUMERIC, 2),
    CURRENT_DATE - (RANDOM() * 90)::INT  -- Last 90 days
FROM products;

-- User recommendations (1M)
INSERT INTO user_recommendations (user_id, product_id, score, generated_at)
SELECT
    (RANDOM() * 999999 + 1)::INT,
    (RANDOM() * 199999 + 1)::INT,
    ROUND(RANDOM()::NUMERIC, 4),
    CURRENT_TIMESTAMP
FROM generate_series(1, 1000000);


-- =====================================================
-- 15. VECTOR EMBEDDINGS (SIMULATED)
-- =====================================================
-- Populate 384-dimensional vectors for all products.
-- In production, these come from an embedding model (e.g. MiniLM).

UPDATE products
SET embedding = (
    SELECT ARRAY(
        SELECT RANDOM()
        FROM generate_series(1, 384)
    )::vector
);


-- =====================================================
-- 16. FULL-TEXT SEARCH VECTORS
-- =====================================================
-- Populate tsvector for text search (if triggers aren't active yet).

UPDATE products
SET search_vector = to_tsvector('english',
    COALESCE(product_name, '') || ' ' || COALESCE(description, '')
);
