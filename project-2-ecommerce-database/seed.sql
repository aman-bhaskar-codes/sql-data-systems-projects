-- =====================================================
-- E-COMMERCE MARKETPLACE DATA SEED (LARGE DATASET)
-- Generates ~15–16 Million Rows
-- =====================================================

-- =====================================================
-- CLEAN DATABASE (SAFE RERUN)
-- =====================================================

TRUNCATE TABLE
search_logs,
product_views,
review_votes,
reviews,
shipment_tracking,
shipments,
refunds,
payments,
order_items,
orders,
cart_items,
carts,
inventory_movements,
inventory,
warehouses,
product_tags,
product_attributes,
product_images,
products,
seller_addresses,
sellers,
user_sessions,
user_addresses,
users,
categories
RESTART IDENTITY CASCADE;

-- =====================================================
-- CATEGORY DATA
-- =====================================================

INSERT INTO categories (category_name)
SELECT 'Category ' || gs
FROM generate_series(1,100) gs;

-- =====================================================
-- USERS (1M)
-- =====================================================

INSERT INTO users (full_name,email,phone)
SELECT
'User ' || gs,
'user' || gs || '@mail.com',
(9000000000 + gs)::text
FROM generate_series(1,1000000) gs;

-- =====================================================
-- USER ADDRESSES
-- =====================================================

INSERT INTO user_addresses (user_id,street,city,state)
SELECT
user_id,
'Street ' || user_id,
'City ' || (random()*20)::int,
'State ' || (random()*10)::int
FROM users;

-- =====================================================
-- USER SESSIONS
-- =====================================================

INSERT INTO user_sessions (user_id,logout_time)
SELECT
user_id,
CURRENT_TIMESTAMP + ((random()*10)::int * interval '1 minute')
FROM users
WHERE random() < 0.4;

-- =====================================================
-- SELLERS (2000)
-- =====================================================

INSERT INTO sellers (seller_name,email,rating)
SELECT
'Seller ' || gs,
'seller' || gs || '@shop.com',
round((random()*5)::numeric,2)
FROM generate_series(1,2000) gs;

-- =====================================================
-- SELLER ADDRESSES
-- =====================================================

INSERT INTO seller_addresses (seller_id,street,city,state)
SELECT
seller_id,
'Street ' || seller_id,
'City ' || (random()*20)::int,
'State ' || (random()*10)::int
FROM sellers;

-- =====================================================
-- PRODUCTS (200K)
-- =====================================================

INSERT INTO products (seller_id,category_id,product_name,price)
SELECT
(random()*1999 + 1)::int,
(random()*99 + 1)::int,
'Product ' || gs,
round((random()*1000 + 10)::numeric,2)
FROM generate_series(1,200000) gs;

-- =====================================================
-- PRODUCT IMAGES
-- =====================================================

INSERT INTO product_images (product_id,image_url)
SELECT
product_id,
'https://img.store.com/' || product_id || '.jpg'
FROM products;

-- =====================================================
-- PRODUCT ATTRIBUTES
-- =====================================================

INSERT INTO product_attributes (product_id,attribute_name,attribute_value)
SELECT
product_id,
'color',
CASE
WHEN random() < 0.3 THEN 'red'
WHEN random() < 0.6 THEN 'blue'
ELSE 'black'
END
FROM products
WHERE random() < 0.5;

-- =====================================================
-- PRODUCT TAGS
-- =====================================================

INSERT INTO product_tags (product_id,tag_name)
SELECT
product_id,
CASE
WHEN random() < 0.5 THEN 'popular'
ELSE 'sale'
END
FROM products
WHERE random() < 0.4;

-- =====================================================
-- WAREHOUSES
-- =====================================================

INSERT INTO warehouses (warehouse_name,city,state)
SELECT
'Warehouse ' || gs,
'City ' || gs,
'State ' || gs
FROM generate_series(1,20) gs;

-- =====================================================
-- INVENTORY
-- =====================================================

INSERT INTO inventory (product_id,warehouse_id,stock_quantity)
SELECT
product_id,
(random()*19 + 1)::int,
(random()*500)::int
FROM products;

-- =====================================================
-- INVENTORY MOVEMENTS (1M)
-- =====================================================

INSERT INTO inventory_movements
(product_id,warehouse_id,quantity_change,movement_type)
SELECT
(random()*199999 + 1)::int,
(random()*19 + 1)::int,
(random()*50)::int,
CASE
WHEN random() < 0.5 THEN 'restock'
ELSE 'sale'
END
FROM generate_series(1,1000000);

-- =====================================================
-- CARTS
-- =====================================================

INSERT INTO carts (user_id)
SELECT user_id
FROM users
WHERE random() < 0.6;

-- =====================================================
-- CART ITEMS
-- =====================================================

INSERT INTO cart_items (cart_id,product_id,quantity)
SELECT
cart_id,
(random()*199999 + 1)::int,
(random()*5 + 1)::int
FROM carts;

-- =====================================================
-- ORDERS (2M)
-- =====================================================

INSERT INTO orders (user_id,total_amount,order_status)
SELECT
(random()*999999 + 1)::int,
round((random()*2000 + 50)::numeric,2),
CASE
WHEN random() < 0.2 THEN 'pending'
WHEN random() < 0.4 THEN 'processing'
WHEN random() < 0.7 THEN 'shipped'
ELSE 'delivered'
END
FROM generate_series(1,2000000);

-- =====================================================
-- ORDER ITEMS (5M)
-- =====================================================

INSERT INTO order_items (order_id,product_id,quantity,price)
SELECT
(random()*1999999 + 1)::int,
(random()*199999 + 1)::int,
(random()*3 + 1)::int,
round((random()*1000 + 10)::numeric,2)
FROM generate_series(1,5000000);

-- =====================================================
-- PAYMENTS
-- =====================================================

INSERT INTO payments (order_id,payment_method,payment_status,amount)
SELECT
order_id,
CASE
WHEN random() < 0.5 THEN 'card'
WHEN random() < 0.8 THEN 'upi'
ELSE 'wallet'
END,
'completed',
total_amount
FROM orders;

-- =====================================================
-- REFUNDS
-- =====================================================

INSERT INTO refunds (payment_id,refund_amount,refund_reason)
SELECT
payment_id,
amount,
'customer request'
FROM payments
WHERE random() < 0.05;

-- =====================================================
-- SHIPMENTS
-- =====================================================

INSERT INTO shipments (order_id,warehouse_id,shipment_status)
SELECT
order_id,
(random()*19 + 1)::int,
'processing'
FROM orders;

-- =====================================================
-- SHIPMENT TRACKING
-- =====================================================

INSERT INTO shipment_tracking (shipment_id,status,location)
SELECT
shipment_id,
CASE
WHEN random() < 0.3 THEN 'processing'
WHEN random() < 0.6 THEN 'in transit'
ELSE 'delivered'
END,
'City ' || (random()*20)::int
FROM shipments;

-- =====================================================
-- REVIEWS (500K)
-- =====================================================

INSERT INTO reviews (user_id,product_id,rating,review_text)
SELECT
(random()*999999 + 1)::int,
(random()*199999 + 1)::int,
(random()*4 + 1)::int,
'Great product!'
FROM generate_series(1,500000);

-- =====================================================
-- REVIEW VOTES
-- =====================================================

INSERT INTO review_votes (review_id,user_id,vote_type)
SELECT
(random()*499999 + 1)::int,
(random()*999999 + 1)::int,
CASE
WHEN random() < 0.7 THEN 'helpful'
ELSE 'not_helpful'
END
FROM generate_series(1,800000);

-- =====================================================
-- PRODUCT VIEWS (3M)
-- =====================================================

INSERT INTO product_views (user_id,product_id)
SELECT
(random()*999999 + 1)::int,
(random()*199999 + 1)::int
FROM generate_series(1,3000000);

-- =====================================================
-- SEARCH LOGS (2M)
-- =====================================================

INSERT INTO search_logs (user_id,search_query)
SELECT
(random()*999999 + 1)::int,
'search term ' || (random()*1000)::int
FROM generate_series(1,2000000);
