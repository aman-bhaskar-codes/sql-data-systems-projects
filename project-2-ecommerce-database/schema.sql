-- =====================================================
-- ADVANCED E-COMMERCE MARKETPLACE DATABASE (FINAL CLEAN)
-- =====================================================

-- =====================================================
-- ENUM TYPES
-- =====================================================

CREATE TYPE order_status_enum AS ENUM (
'pending','confirmed','shipped','delivered','cancelled'
);

CREATE TYPE payment_status_enum AS ENUM (
'pending','completed','failed','refunded'
);

CREATE TYPE shipment_status_enum AS ENUM (
'processing','shipped','in_transit','delivered'
);

-- =====================================================
-- CATEGORY SYSTEM
-- =====================================================

CREATE TABLE categories (
category_id SERIAL PRIMARY KEY,
category_name TEXT NOT NULL,
parent_category_id INT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


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
is_active BOOLEAN DEFAULT TRUE,
is_deleted BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP
);

CREATE TABLE user_addresses (
address_id BIGSERIAL PRIMARY KEY,
user_id BIGINT NOT NULL,
street TEXT NOT NULL,
city TEXT NOT NULL,
state TEXT NOT NULL,
postal_code TEXT,
country TEXT DEFAULT 'India',


FOREIGN KEY(user_id)
REFERENCES users(user_id)


);

CREATE TABLE user_sessions (
session_id BIGSERIAL PRIMARY KEY,
user_id BIGINT NOT NULL,
login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
logout_time TIMESTAMP,


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
is_deleted BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP,
embedding FLOAT[],
search_vector tsvector,


FOREIGN KEY(seller_id)
REFERENCES sellers(seller_id),

FOREIGN KEY(category_id)
REFERENCES categories(category_id)


);

CREATE TABLE product_images (
image_id BIGSERIAL PRIMARY KEY,
product_id BIGINT NOT NULL,
image_url TEXT NOT NULL,


FOREIGN KEY(product_id)
REFERENCES products(product_id)


);

CREATE TABLE product_attributes (
attribute_id BIGSERIAL PRIMARY KEY,
product_id BIGINT NOT NULL,
attribute_name TEXT,
attribute_value TEXT,


FOREIGN KEY(product_id)
REFERENCES products(product_id)


);

CREATE TABLE product_tags (
tag_id BIGSERIAL PRIMARY KEY,
product_id BIGINT NOT NULL,
tag_name TEXT,


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
stock_quantity INT CHECK (stock_quantity >= 0),


UNIQUE(product_id, warehouse_id),

FOREIGN KEY(product_id)
REFERENCES products(product_id),

FOREIGN KEY(warehouse_id)
REFERENCES warehouses(warehouse_id)


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


FOREIGN KEY(user_id)
REFERENCES users(user_id)


);

CREATE TABLE cart_items (
cart_item_id BIGSERIAL PRIMARY KEY,
cart_id BIGINT NOT NULL,
product_id BIGINT NOT NULL,
quantity INT NOT NULL,


FOREIGN KEY(cart_id)
REFERENCES carts(cart_id),

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
order_status order_status_enum DEFAULT 'pending',
total_amount NUMERIC(12,2),
updated_at TIMESTAMP,


FOREIGN KEY(user_id)
REFERENCES users(user_id)


);

CREATE TABLE order_items (
order_item_id BIGSERIAL PRIMARY KEY,
order_id BIGINT NOT NULL,
product_id BIGINT NOT NULL,
quantity INT NOT NULL,
price NUMERIC(10,2),


FOREIGN KEY(order_id)
REFERENCES orders(order_id),

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
payment_status payment_status_enum DEFAULT 'pending',
amount NUMERIC(12,2) NOT NULL,
payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP,


FOREIGN KEY(order_id)
REFERENCES orders(order_id)


);

CREATE TABLE refunds (
refund_id BIGSERIAL PRIMARY KEY,
payment_id BIGINT NOT NULL,
refund_amount NUMERIC(10,2),
refund_reason TEXT,
refund_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


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
shipment_status shipment_status_enum DEFAULT 'processing',
shipped_date TIMESTAMP,
delivered_date TIMESTAMP,


FOREIGN KEY(order_id)
REFERENCES orders(order_id),

FOREIGN KEY(warehouse_id)
REFERENCES warehouses(warehouse_id)


);

CREATE TABLE shipment_tracking (
tracking_id BIGSERIAL PRIMARY KEY,
shipment_id BIGINT,
status TEXT,
location TEXT,
update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


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


FOREIGN KEY(user_id)
REFERENCES users(user_id),

FOREIGN KEY(product_id)
REFERENCES products(product_id)


);

CREATE TABLE review_votes (
vote_id BIGSERIAL PRIMARY KEY,
review_id BIGINT,
user_id BIGINT,
vote_type TEXT,


FOREIGN KEY(review_id)
REFERENCES reviews(review_id),

FOREIGN KEY(user_id)
REFERENCES users(user_id)


);

-- =====================================================
-- ANALYTICS / ACTIVITY
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

-- =====================================================
-- AI / ADVANCED TABLES
-- =====================================================

CREATE TABLE product_metadata (
metadata_id BIGSERIAL PRIMARY KEY,
product_id BIGINT NOT NULL,
metadata JSONB,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,


FOREIGN KEY(product_id)
REFERENCES products(product_id)


);

CREATE TABLE system_events (
event_id BIGSERIAL PRIMARY KEY,
user_id BIGINT,
event_type TEXT,
event_data JSONB,
event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_features (
user_id BIGINT PRIMARY KEY,
total_orders INT,
total_spent NUMERIC,
avg_order_value NUMERIC,
favorite_category INT
);

CREATE TABLE product_features (
product_id BIGINT PRIMARY KEY,
popularity_score NUMERIC,
avg_rating NUMERIC,
total_sales INT
);

CREATE TABLE product_relationships (
relation_id BIGSERIAL PRIMARY KEY,
product_a BIGINT,
product_b BIGINT,
relation_type TEXT
);

CREATE TABLE product_metrics_daily (
metric_id BIGSERIAL PRIMARY KEY,
product_id BIGINT,
views INT,
purchases INT,
revenue NUMERIC,
metric_date DATE
);

CREATE TABLE user_recommendations (
user_id BIGINT,
product_id BIGINT,
score NUMERIC,
generated_at TIMESTAMP
);
