-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — SCHEMA DEFINITION
-- ============================================================
-- 30 production-grade tables modeling a full e-commerce system:
--   Users, Sellers, Products, Orders, Payments, Shipping,
--   Inventory, Reviews, Cart, Analytics, and AI/Vector layers.
--
-- Run AFTER: setup_database.sql
-- ============================================================


-- =====================================================
-- CUSTOM ENUM TYPES
-- =====================================================

CREATE TYPE order_status_enum AS ENUM (
    'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
);

CREATE TYPE payment_status_enum AS ENUM (
    'pending', 'completed', 'failed', 'refunded'
);

CREATE TYPE shipment_status_enum AS ENUM (
    'processing', 'shipped', 'in_transit', 'delivered'
);


-- =====================================================
-- 1. CATEGORY SYSTEM (self-referencing hierarchy)
-- =====================================================

CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL,
    parent_category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- 2. USER SYSTEM
-- =====================================================

CREATE TABLE users (
    user_id    BIGSERIAL PRIMARY KEY,
    full_name  TEXT NOT NULL,
    email      TEXT UNIQUE NOT NULL,
    phone      TEXT UNIQUE,
    is_active  BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE user_addresses (
    address_id  BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    street      TEXT NOT NULL,
    city        TEXT NOT NULL,
    state       TEXT NOT NULL,
    postal_code TEXT,
    country     TEXT DEFAULT 'India'
);

CREATE TABLE user_sessions (
    session_id  BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    login_time  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP
);


-- =====================================================
-- 3. SELLER SYSTEM
-- =====================================================

CREATE TABLE sellers (
    seller_id   BIGSERIAL PRIMARY KEY,
    seller_name TEXT NOT NULL,
    email       TEXT UNIQUE NOT NULL,
    rating      NUMERIC(3,2) DEFAULT 0.00,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE seller_addresses (
    seller_address_id BIGSERIAL PRIMARY KEY,
    seller_id         BIGINT NOT NULL REFERENCES sellers(seller_id) ON DELETE CASCADE,
    street            TEXT,
    city              TEXT,
    state             TEXT
);


-- =====================================================
-- 4. PRODUCT CATALOG (with AI columns)
-- =====================================================

CREATE TABLE products (
    product_id    BIGSERIAL PRIMARY KEY,
    seller_id     BIGINT NOT NULL REFERENCES sellers(seller_id) ON DELETE CASCADE,
    category_id   INT NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    product_name  TEXT NOT NULL,
    price         NUMERIC(10,2) NOT NULL CHECK (price > 0),
    description   TEXT,
    is_deleted    BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP,

    -- AI: vector embedding for semantic similarity (384-dim, MiniLM-class models)
    embedding     vector(384),

    -- Full-text search vector (auto-populated via trigger)
    search_vector tsvector
);

CREATE TABLE product_images (
    image_id   BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    image_url  TEXT NOT NULL
);

CREATE TABLE product_attributes (
    attribute_id    BIGSERIAL PRIMARY KEY,
    product_id      BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    attribute_name  TEXT NOT NULL,
    attribute_value TEXT NOT NULL
);

CREATE TABLE product_tags (
    tag_id     BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    tag_name   TEXT NOT NULL
);

CREATE TABLE product_metadata (
    metadata_id BIGSERIAL PRIMARY KEY,
    product_id  BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    metadata    JSONB NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- 5. INVENTORY & WAREHOUSE SYSTEM
-- =====================================================

CREATE TABLE warehouses (
    warehouse_id   SERIAL PRIMARY KEY,
    warehouse_name TEXT NOT NULL,
    city           TEXT,
    state          TEXT
);

CREATE TABLE inventory (
    inventory_id   BIGSERIAL PRIMARY KEY,
    product_id     BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    warehouse_id   INT NOT NULL REFERENCES warehouses(warehouse_id) ON DELETE CASCADE,
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),

    UNIQUE(product_id, warehouse_id)
);

CREATE TABLE inventory_movements (
    movement_id    BIGSERIAL PRIMARY KEY,
    product_id     BIGINT REFERENCES products(product_id) ON DELETE SET NULL,
    warehouse_id   INT REFERENCES warehouses(warehouse_id) ON DELETE SET NULL,
    quantity_change INT NOT NULL,
    movement_type  TEXT NOT NULL,
    movement_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- 6. CART SYSTEM
-- =====================================================

CREATE TABLE carts (
    cart_id    BIGSERIAL PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cart_items (
    cart_item_id BIGSERIAL PRIMARY KEY,
    cart_id      BIGINT NOT NULL REFERENCES carts(cart_id) ON DELETE CASCADE,
    product_id   BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    quantity     INT NOT NULL CHECK (quantity > 0)
);


-- =====================================================
-- 7. ORDER SYSTEM
-- =====================================================

CREATE TABLE orders (
    order_id     BIGSERIAL PRIMARY KEY,
    user_id      BIGINT NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    order_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status order_status_enum DEFAULT 'pending',
    total_amount NUMERIC(12,2),
    updated_at   TIMESTAMP
);

CREATE TABLE order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id      BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id    BIGINT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity      INT NOT NULL CHECK (quantity > 0),
    price         NUMERIC(10,2) NOT NULL CHECK (price > 0)
);


-- =====================================================
-- 8. PAYMENT SYSTEM
-- =====================================================

CREATE TABLE payments (
    payment_id     BIGSERIAL PRIMARY KEY,
    order_id       BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_method TEXT NOT NULL,
    payment_status payment_status_enum DEFAULT 'pending',
    amount         NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP
);

CREATE TABLE refunds (
    refund_id     BIGSERIAL PRIMARY KEY,
    payment_id    BIGINT NOT NULL REFERENCES payments(payment_id) ON DELETE CASCADE,
    refund_amount NUMERIC(10,2) NOT NULL CHECK (refund_amount > 0),
    refund_reason TEXT,
    refund_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- 9. SHIPPING SYSTEM
-- =====================================================

CREATE TABLE shipments (
    shipment_id     BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    warehouse_id    INT REFERENCES warehouses(warehouse_id) ON DELETE SET NULL,
    shipment_status shipment_status_enum DEFAULT 'processing',
    shipped_date    TIMESTAMP,
    delivered_date  TIMESTAMP
);

CREATE TABLE shipment_tracking (
    tracking_id BIGSERIAL PRIMARY KEY,
    shipment_id BIGINT NOT NULL REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    status      TEXT NOT NULL,
    location    TEXT,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- 10. REVIEW SYSTEM
-- =====================================================

CREATE TABLE reviews (
    review_id   BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id  BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE review_votes (
    vote_id   BIGSERIAL PRIMARY KEY,
    review_id BIGINT NOT NULL REFERENCES reviews(review_id) ON DELETE CASCADE,
    user_id   BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    vote_type TEXT NOT NULL CHECK (vote_type IN ('helpful', 'not_helpful'))
);


-- =====================================================
-- 11. ANALYTICS & EVENT TRACKING
-- =====================================================

CREATE TABLE product_views (
    view_id    BIGSERIAL PRIMARY KEY,
    user_id    BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    product_id BIGINT REFERENCES products(product_id) ON DELETE SET NULL,
    view_time  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE search_logs (
    search_id    BIGSERIAL PRIMARY KEY,
    user_id      BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    search_query TEXT NOT NULL,
    search_time  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE system_events (
    event_id   BIGSERIAL PRIMARY KEY,
    user_id    BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    event_data JSONB,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- 12. AI / FEATURE STORE TABLES
-- =====================================================

-- Pre-computed user behavior features (for ML pipelines)
CREATE TABLE user_features (
    user_id           BIGINT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    total_orders      INT DEFAULT 0,
    total_spent       NUMERIC DEFAULT 0,
    avg_order_value   NUMERIC DEFAULT 0,
    favorite_category INT REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Pre-computed product popularity features
CREATE TABLE product_features (
    product_id       BIGINT PRIMARY KEY REFERENCES products(product_id) ON DELETE CASCADE,
    popularity_score NUMERIC DEFAULT 0,
    avg_rating       NUMERIC DEFAULT 0,
    total_sales      INT DEFAULT 0
);

-- Co-purchase & similarity relationships
CREATE TABLE product_relationships (
    relation_id   BIGSERIAL PRIMARY KEY,
    product_a     BIGINT REFERENCES products(product_id) ON DELETE CASCADE,
    product_b     BIGINT REFERENCES products(product_id) ON DELETE CASCADE,
    relation_type TEXT NOT NULL
);

-- Daily product performance metrics
CREATE TABLE product_metrics_daily (
    metric_id   BIGSERIAL PRIMARY KEY,
    product_id  BIGINT REFERENCES products(product_id) ON DELETE CASCADE,
    views       INT DEFAULT 0,
    purchases   INT DEFAULT 0,
    revenue     NUMERIC DEFAULT 0,
    metric_date DATE NOT NULL
);

-- Pre-computed recommendation cache
CREATE TABLE user_recommendations (
    user_id      BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    product_id   BIGINT REFERENCES products(product_id) ON DELETE CASCADE,
    score        NUMERIC NOT NULL,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, product_id)
);
