-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — TABLE PARTITIONING
-- ============================================================
-- Range partitioning on high-volume tables for query performance.
-- Partitions orders by year and system_events by month.
--
-- Run AFTER: schema.sql (on a fresh database)
-- NOTE: If the orders table already exists, it must be dropped
--       and recreated as a partitioned table.
-- ============================================================


-- =====================================================
-- PARTITIONED ORDERS TABLE
-- =====================================================
-- Strategy: RANGE partition by order_date (yearly)
-- Rationale: Orders table grows to millions of rows.
--            Partitioning enables partition pruning on date queries.

-- Drop original non-partitioned orders table
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS orders CASCADE;

-- Recreate as partitioned
CREATE TABLE orders (
    order_id     BIGSERIAL,
    user_id      BIGINT NOT NULL,
    order_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status order_status_enum DEFAULT 'pending',
    total_amount NUMERIC(12,2),
    updated_at   TIMESTAMP,

    PRIMARY KEY (order_id, order_date),

    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
) PARTITION BY RANGE (order_date);

-- Yearly partitions
CREATE TABLE orders_2024 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE orders_2025 PARTITION OF orders
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE orders_2026 PARTITION OF orders
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- Partition-level indexes (each partition gets its own index)
CREATE INDEX idx_orders_2024_user ON orders_2024(user_id);
CREATE INDEX idx_orders_2025_user ON orders_2025(user_id);
CREATE INDEX idx_orders_2026_user ON orders_2026(user_id);

CREATE INDEX idx_orders_2024_date ON orders_2024(order_date);
CREATE INDEX idx_orders_2025_date ON orders_2025(order_date);
CREATE INDEX idx_orders_2026_date ON orders_2026(order_date);


-- Recreate dependent tables after partitioning
CREATE TABLE order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id      BIGINT NOT NULL,
    order_date    TIMESTAMP NOT NULL,
    product_id    BIGINT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity      INT NOT NULL CHECK (quantity > 0),
    price         NUMERIC(10,2) NOT NULL CHECK (price > 0),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id, order_date) REFERENCES orders(order_id, order_date)
);

CREATE TABLE payments (
    payment_id     BIGSERIAL PRIMARY KEY,
    order_id       BIGINT NOT NULL,
    order_date     TIMESTAMP NOT NULL,
    payment_method TEXT NOT NULL,
    payment_status payment_status_enum DEFAULT 'pending',
    amount         NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP,

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id, order_date) REFERENCES orders(order_id, order_date)
);

CREATE TABLE shipments (
    shipment_id     BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL,
    order_date      TIMESTAMP NOT NULL,
    warehouse_id    INT REFERENCES warehouses(warehouse_id) ON DELETE SET NULL,
    shipment_status shipment_status_enum DEFAULT 'processing',
    shipped_date    TIMESTAMP,
    delivered_date  TIMESTAMP,

    CONSTRAINT fk_shipments_order
        FOREIGN KEY (order_id, order_date) REFERENCES orders(order_id, order_date)
);


-- =====================================================
-- PARTITIONED SYSTEM EVENTS TABLE
-- =====================================================
-- Strategy: RANGE partition by event_time (yearly)
-- Rationale: Event tracking tables grow fastest (~millions/month).

DROP TABLE IF EXISTS system_events CASCADE;

CREATE TABLE system_events (
    event_id   BIGSERIAL,
    user_id    BIGINT,
    event_type TEXT NOT NULL,
    event_data JSONB,
    event_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (event_id, event_time)
) PARTITION BY RANGE (event_time);

CREATE TABLE events_2024 PARTITION OF system_events
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE events_2025 PARTITION OF system_events
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE events_2026 PARTITION OF system_events
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
