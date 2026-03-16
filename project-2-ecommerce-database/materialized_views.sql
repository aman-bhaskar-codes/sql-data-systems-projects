CREATE MATERIALIZED VIEW seller_revenue AS
SELECT
p.seller_id,
SUM(oi.quantity * oi.price) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.seller_id;