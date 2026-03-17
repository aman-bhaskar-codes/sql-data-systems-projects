-- DROP original orders table
DROP TABLE orders CASCADE;



-- PARTITIONED ORDERS TABLE

CREATE TABLE orders (
    order_id BIGSERIAL,
    user_id BIGINT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    order_status TEXT DEFAULT 'pending',
    total_amount NUMERIC(12,2),

    PRIMARY KEY(order_id, order_date),

    CONSTRAINT fk_orders_user
    FOREIGN KEY(user_id)
    REFERENCES users(user_id)

) PARTITION BY RANGE (order_date);


-- =====================================================
-- PARTITIONS FOR ORDERS
-- =====================================================

CREATE TABLE orders_2024
PARTITION OF orders
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE orders_2025
PARTITION OF orders
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE orders_2026
PARTITION OF orders
FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');


