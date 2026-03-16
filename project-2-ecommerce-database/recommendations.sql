SELECT
oi1.product_id AS product_a,
oi2.product_id AS product_b,
COUNT(*) AS frequency
FROM order_items oi1
JOIN order_items oi2
ON oi1.order_id = oi2.order_id
AND oi1.product_id <> oi2.product_id
GROUP BY product_a, product_b
ORDER BY frequency DESC
LIMIT 20;