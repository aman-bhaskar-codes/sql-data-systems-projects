-- =====================================================
-- ADVANCED E-COMMERCE MARKETPLACE DATABASE
-- PostgreSQL Portfolio Project
-- =====================================================


-- =====================================================
-- CATEGORY SYSTEM
-- =====================================================

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_category_parent
        FOREIGN KEY(parent_category_id)
        REFERENCES categories(category_id)
);



-- =====================================================
-- USER SYSTEM
-- =====================================================

CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);


CREATE TABLE user_addresses (
    address_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    street TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    postal_code TEXT,
    country TEXT DEFAULT 'India',

    CONSTRAINT fk_address_user
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
);


CREATE TABLE user_sessions (
    session_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP,

    CONSTRAINT fk_session_user
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
);



-- =====================================================
-- SELLER SYSTEM
-- =====================================================

CREATE TABLE sellers (
    seller_id BIGSERIAL PRIMARY KEY,
    seller_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    rating NUMERIC(3,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE seller_addresses (
    seller_address_id BIGSERIAL PRIMARY KEY,
    seller_id BIGINT NOT NULL,
    street TEXT,
    city TEXT,
    state TEXT,

    CONSTRAINT fk_seller_address
        FOREIGN KEY(seller_id)
        REFERENCES sellers(seller_id)
);



-- =====================================================
-- PRODUCT CATALOG
-- =====================================================

CREATE TABLE products (
    product_id BIGSERIAL PRIMARY KEY,
    seller_id BIGINT NOT NULL,
    category_id INT NOT NULL,
    product_name TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_products_seller
        FOREIGN KEY(seller_id)
        REFERENCES sellers(seller_id),

    CONSTRAINT fk_products_category
        FOREIGN KEY(category_id)
        REFERENCES categories(category_id)
);


CREATE TABLE product_images (
    image_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_url TEXT NOT NULL,

    CONSTRAINT fk_image_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)
);


CREATE TABLE product_attributes (
    attribute_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    attribute_name TEXT,
    attribute_value TEXT,

    CONSTRAINT fk_attribute_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)
);


CREATE TABLE product_tags (
    tag_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    tag_name TEXT,

    CONSTRAINT fk_tag_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)
);



-- =====================================================
-- INVENTORY SYSTEM
-- =====================================================

CREATE TABLE warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    warehouse_name TEXT NOT NULL,
    city TEXT,
    state TEXT
);


CREATE TABLE inventory (
    inventory_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    warehouse_id INT NOT NULL,
    stock_quantity INT DEFAULT 0,

    CONSTRAINT fk_inventory_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id),

    CONSTRAINT fk_inventory_warehouse
        FOREIGN KEY(warehouse_id)
        REFERENCES warehouses(warehouse_id),

    CONSTRAINT unique_product_warehouse
        UNIQUE(product_id, warehouse_id)
);


CREATE TABLE inventory_movements (
    movement_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT,
    warehouse_id INT,
    quantity_change INT,
    movement_type TEXT,
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- =====================================================
-- CART SYSTEM
-- =====================================================

CREATE TABLE carts (
    cart_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cart_user
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
);


CREATE TABLE cart_items (
    cart_item_id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT,

    CONSTRAINT fk_cart_item_cart
        FOREIGN KEY(cart_id)
        REFERENCES carts(cart_id),

    CONSTRAINT fk_cart_item_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)
);



-- =====================================================
-- ORDER SYSTEM
-- =====================================================

CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status TEXT DEFAULT 'pending',
    total_amount NUMERIC(12,2),

    CONSTRAINT fk_orders_user
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
);


CREATE TABLE order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT,
    price NUMERIC(10,2),

    CONSTRAINT fk_order_item_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_item_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)
);



-- =====================================================
-- PAYMENT SYSTEM
-- =====================================================

CREATE TABLE payments (
    payment_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    payment_method TEXT,
    payment_status TEXT DEFAULT 'pending',
    amount NUMERIC(12,2),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payment_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id)
);


CREATE TABLE refunds (
    refund_id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT NOT NULL,
    refund_amount NUMERIC(10,2),
    refund_reason TEXT,
    refund_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_refund_payment
        FOREIGN KEY(payment_id)
        REFERENCES payments(payment_id)
);



-- =====================================================
-- SHIPPING SYSTEM
-- =====================================================

CREATE TABLE shipments (
    shipment_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT,
    warehouse_id INT,
    shipment_status TEXT DEFAULT 'processing',
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP,

    CONSTRAINT fk_shipment_order
        FOREIGN KEY(order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_shipment_warehouse
        FOREIGN KEY(warehouse_id)
        REFERENCES warehouses(warehouse_id)
);


CREATE TABLE shipment_tracking (
    tracking_id BIGSERIAL PRIMARY KEY,
    shipment_id BIGINT,
    status TEXT,
    location TEXT,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tracking_shipment
        FOREIGN KEY(shipment_id)
        REFERENCES shipments(shipment_id)
);



-- =====================================================
-- REVIEW SYSTEM
-- =====================================================

CREATE TABLE reviews (
    review_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    product_id BIGINT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_review_user
        FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_review_product
        FOREIGN KEY(product_id)
        REFERENCES products(product_id)
);


CREATE TABLE review_votes (
    vote_id BIGSERIAL PRIMARY KEY,
    review_id BIGINT,
    user_id BIGINT,
    vote_type TEXT,

    CONSTRAINT fk_vote_review
        FOREIGN KEY(review_id)
        REFERENCES reviews(review_id),

    CONSTRAINT fk_vote_user
        FOREIGN KEY(user_id)
        REFERENCES users(user_id)
);



-- =====================================================
-- ANALYTICS / ACTIVITY SYSTEM
-- =====================================================

CREATE TABLE product_views (
    view_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    product_id BIGINT,
    view_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE search_logs (
    search_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    search_query TEXT,
    search_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);