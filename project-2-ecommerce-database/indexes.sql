-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — PERFORMANCE INDEXES
-- ============================================================
-- Strategic indexes for large-scale query optimization.
-- Covers B-Tree, GIN (JSONB + full-text), and IVFFLAT (vector).
--
-- Run AFTER: schema.sql
-- ============================================================


-- =====================================================
-- USER INDEXES
-- =====================================================

-- Case-insensitive email lookups
CREATE INDEX idx_users_email_lower
    ON users (LOWER(email));


-- =====================================================
-- PRODUCT INDEXES
-- =====================================================

-- Filter by category
CREATE INDEX idx_products_category
    ON products(category_id);

-- Filter by seller
CREATE INDEX idx_products_seller
    ON products(seller_id);

-- Composite: category + price range filtering
CREATE INDEX idx_products_category_price
    ON products(category_id, price);

-- GIN index on full-text search vector
CREATE INDEX idx_products_search
    ON products USING GIN(search_vector);

-- IVFFLAT index on vector embeddings (cosine distance)
-- lists = 100 optimizes for ~200K products
CREATE INDEX idx_products_embedding_ivfflat
    ON products USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);


-- =====================================================
-- ORDER INDEXES
-- =====================================================

-- Find orders by user
CREATE INDEX idx_orders_user
    ON orders(user_id);

-- Query orders by date (range scans)
CREATE INDEX idx_orders_date
    ON orders(order_date);

-- Partial index: only pending orders (hot path)
CREATE INDEX idx_orders_pending
    ON orders(order_date)
    WHERE order_status = 'pending';


-- =====================================================
-- ORDER ITEMS INDEXES
-- =====================================================

-- JOIN optimization with orders
CREATE INDEX idx_order_items_order
    ON order_items(order_id);

-- Product analytics / revenue queries
CREATE INDEX idx_order_items_product
    ON order_items(product_id);


-- =====================================================
-- INVENTORY INDEXES
-- =====================================================

-- Stock lookup by product
CREATE INDEX idx_inventory_product
    ON inventory(product_id);

-- Warehouse-level queries
CREATE INDEX idx_inventory_warehouse
    ON inventory(warehouse_id);


-- =====================================================
-- REVIEW INDEXES
-- =====================================================

-- Average rating per product
CREATE INDEX idx_reviews_product
    ON reviews(product_id);

-- User review history
CREATE INDEX idx_reviews_user
    ON reviews(user_id);


-- =====================================================
-- PAYMENT & SHIPPING INDEXES
-- =====================================================

-- Join payments with orders
CREATE INDEX idx_payments_order
    ON payments(order_id);

-- Track shipments per order
CREATE INDEX idx_shipments_order
    ON shipments(order_id);


-- =====================================================
-- ANALYTICS INDEXES
-- =====================================================

-- Product view analytics
CREATE INDEX idx_product_views_product
    ON product_views(product_id);

CREATE INDEX idx_product_views_user
    ON product_views(user_id);

-- Search analytics
CREATE INDEX idx_search_logs_user
    ON search_logs(user_id);

-- Event system
CREATE INDEX idx_events_user
    ON system_events(user_id);

CREATE INDEX idx_events_type
    ON system_events(event_type);


-- =====================================================
-- JSONB INDEXES (GIN)
-- =====================================================

-- Fast JSONB containment queries on product metadata
CREATE INDEX idx_metadata_json
    ON product_metadata USING GIN(metadata);

-- Fast JSONB queries on event payloads
CREATE INDEX idx_events_data
    ON system_events USING GIN(event_data);


-- =====================================================
-- DAILY METRICS INDEX
-- =====================================================

CREATE INDEX idx_metrics_product_date
    ON product_metrics_daily(product_id, metric_date);
