-- USER AUTO SETUP

CREATE OR REPLACE FUNCTION create_user_defaults()
RETURNS TRIGGER AS $$
BEGIN

INSERT INTO carts(user_id) VALUES (NEW.user_id);
INSERT INTO user_sessions(user_id) VALUES (NEW.user_id);

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_defaults
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION create_user_defaults();



-- INVENTORY AUTO UPDATE

CREATE OR REPLACE FUNCTION update_inventory_after_order()
RETURNS TRIGGER AS $$
BEGIN

UPDATE inventory
SET stock_quantity = stock_quantity - NEW.quantity
WHERE product_id = NEW.product_id;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventory_update
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_inventory_after_order();


-- =====================================================
-- TRIGGERS (AUTOMATION + DATA INTEGRITY)
-- =====================================================

-- ============================
-- AUTO UPDATE TIMESTAMP
-- ============================

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_update
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_orders_update
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_products_update
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- ============================
-- ORDER TOTAL VALIDATION
-- ============================

CREATE OR REPLACE FUNCTION validate_order_total()
RETURNS TRIGGER AS $$
DECLARE total NUMERIC;
BEGIN

SELECT SUM(quantity * price)
INTO total
FROM order_items
WHERE order_id = NEW.order_id;

UPDATE orders
SET total_amount = total
WHERE order_id = NEW.order_id;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_total
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION validate_order_total();

-- ============================
-- PREVENT NEGATIVE INVENTORY
-- ============================

CREATE OR REPLACE FUNCTION prevent_negative_inventory()
RETURNS TRIGGER AS $$
BEGIN

IF NEW.stock_quantity < 0 THEN
RAISE EXCEPTION 'Stock cannot be negative';
END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_no_negative_stock
BEFORE UPDATE ON inventory
FOR EACH ROW
EXECUTE FUNCTION prevent_negative_inventory();
