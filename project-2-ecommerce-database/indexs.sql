-- =====================================================
-- E-COMMERCE MARKETPLACE DATABASE
-- PERFORMANCE INDEXES
-- =====================================================
-- This file contains all indexes used to optimize
-- query performance for large datasets (millions of rows)
-- =====================================================

-- =====================================================
-- USERS INDEXES
-- =====================================================

-- Fast lookup by email
CREATE INDEX idx_users_email
ON users(email);

-- Case-insensitive email search
CREATE INDEX idx_users_email_lower
ON users (LOWER(email));

-- =====================================================
-- PRODUCTS INDEXES
-- =====================================================

-- Filter products by category
CREATE INDEX idx_products_category
ON products(category_id);

-- Filter products by seller
CREATE INDEX idx_products_seller
ON products(seller_id);

-- Composite index for category + price filtering
CREATE INDEX idx_products_category_price
ON products(category_id, price);

-- =====================================================
-- ORDERS INDEXES
-- =====================================================

-- Find orders by user
CREATE INDEX idx_orders_user
ON orders(user_id);

-- Query orders by date
CREATE INDEX idx_orders_date
ON orders(order_date);

-- Partial index for active/pending orders
CREATE INDEX idx_orders_pending
ON orders(order_date)
WHERE order_status = 'pending';

-- =====================================================
-- ORDER ITEMS INDEXES
-- =====================================================

-- Join optimization with orders
CREATE INDEX idx_order_items_order
ON order_items(order_id);

-- Product analytics queries
CREATE INDEX idx_order_items_product
ON order_items(product_id);

-- =====================================================
-- INVENTORY INDEXES
-- =====================================================

-- Lookup inventory by product
CREATE INDEX idx_inventory_product
ON inventory(product_id);

-- Warehouse stock lookup
CREATE INDEX idx_inventory_warehouse
ON inventory(warehouse_id);

-- =====================================================
-- REVIEWS INDEXES
-- =====================================================

-- Average rating queries per product
CREATE INDEX idx_reviews_product
ON reviews(product_id);

-- User review history
CREATE INDEX idx_reviews_user
ON reviews(user_id);

-- =====================================================
-- PAYMENTS INDEXES
-- =====================================================

-- Join payments with orders
CREATE INDEX idx_payments_order
ON payments(order_id);

-- =====================================================
-- SHIPMENTS INDEXES
-- =====================================================

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



