-- ============================================================
-- AI-READY E-COMMERCE DATA PLATFORM — TRIGGERS & AUTOMATION
-- ============================================================
-- Automated business logic enforced at the database level:
--   - Timestamp updates
--   - Inventory management
--   - Order total calculation
--   - Negative stock prevention
--   - Search vector maintenance
--
-- Run AFTER: schema.sql
-- ============================================================


-- =====================================================
-- 1. AUTO-UPDATE TIMESTAMPS
-- =====================================================
-- Automatically sets updated_at on any row modification.

CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_timestamp
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_orders_timestamp
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_products_timestamp
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

CREATE TRIGGER trg_payments_timestamp
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();


-- =====================================================
-- 2. AUTO-CREATE USER DEFAULTS
-- =====================================================
-- When a new user is created, automatically create their cart.

CREATE OR REPLACE FUNCTION fn_create_user_defaults()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO carts (user_id) VALUES (NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_defaults
    AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION fn_create_user_defaults();


-- =====================================================
-- 3. AUTO-DEDUCT INVENTORY ON ORDER
-- =====================================================
-- When an order item is inserted, reduce stock quantity.

CREATE OR REPLACE FUNCTION fn_deduct_inventory()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE inventory
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    -- Log the movement
    INSERT INTO inventory_movements
        (product_id, warehouse_id, quantity_change, movement_type)
    SELECT
        NEW.product_id, warehouse_id, -NEW.quantity, 'sale'
    FROM inventory
    WHERE product_id = NEW.product_id
    LIMIT 1;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventory_deduct
    AFTER INSERT ON order_items
    FOR EACH ROW EXECUTE FUNCTION fn_deduct_inventory();


-- =====================================================
-- 4. AUTO-CALCULATE ORDER TOTAL
-- =====================================================
-- Recalculates order total_amount after each item is added.

CREATE OR REPLACE FUNCTION fn_recalculate_order_total()
RETURNS TRIGGER AS $$
DECLARE
    new_total NUMERIC;
BEGIN
    SELECT SUM(quantity * price)
    INTO new_total
    FROM order_items
    WHERE order_id = NEW.order_id;

    UPDATE orders
    SET total_amount = new_total
    WHERE order_id = NEW.order_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_total
    AFTER INSERT ON order_items
    FOR EACH ROW EXECUTE FUNCTION fn_recalculate_order_total();


-- =====================================================
-- 5. PREVENT NEGATIVE INVENTORY
-- =====================================================
-- Raises an exception if stock would go below zero.

CREATE OR REPLACE FUNCTION fn_prevent_negative_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock_quantity < 0 THEN
        RAISE EXCEPTION 'Stock cannot be negative for product_id=%', NEW.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_no_negative_stock
    BEFORE UPDATE ON inventory
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_negative_stock();


-- =====================================================
-- 6. AUTO-MAINTAIN SEARCH VECTOR
-- =====================================================
-- Automatically updates the tsvector when product name/description changes.

CREATE OR REPLACE FUNCTION fn_update_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector = to_tsvector('english',
        COALESCE(NEW.product_name, '') || ' ' || COALESCE(NEW.description, '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_products_search_vector
    BEFORE INSERT OR UPDATE OF product_name, description ON products
    FOR EACH ROW EXECUTE FUNCTION fn_update_search_vector();
