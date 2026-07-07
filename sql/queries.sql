--- Main dataset
SELECT	o.order_id,
		o.order_purchase_t,
        strftime('%Y-%m', o.order_purchase_t) AS purch_mon,
        c.customer_state,
        t.product_category_1 AS category,
        i.price,
        i.freight_value,
        r.review_score,
        p.payment_type AS pay_method,
        o.order_status
FROM olist_order_items_dataset i
INNER JOIN olist_orders_dataset o USING(order_id)
INNER JOIN olist_customers_dataset c USING(customer_id)
INNER JOIN olist_products_dataset pr ON pr.product_id = i.product_id
LEFT JOIN product_category_name_translation t ON t.product_category = pr.product_category
LEFT JOIN olist_order_reviews_dataset r USING(order_id)
LEFT JOIN olist_order_payments_dataset p USING(order_id)
WHERE o.order_status = 'delivered';

--- Monthly revenue  and count of orders
SELECT	strftime('%Y-%m', o.order_purchase_t) AS purch_mon,
		ROUND(SUM(i.price), 2) AS revenue,
        COUNT(DISTINCT o.order_id) AS orders
FROM olist_order_items_dataset i
JOIN olist_orders_dataset o USING(order_id)
WHERE o.order_status = 'delivered'
GROUP BY purch_mon
ORDER BY purch_mon;
--------------------------------------------------------------------------------------------------------------------
-- TOP-10 by revenue
-- Result:
-- 1 - health_beauty(1233131.72)
-- 2 - watches_gifts(1166176.98)
-- 3 - bed_bath_table(1023434.76)
-- 4 - sports_leisure(954852.55)
-- 5 - computers_accessories(888724.61)
-- 6 - furniture_decor(711927.69)
-- 7 - housewares(615628.69)
-- 8 - cool_stuff(610204.1)
-- 9 - auto(578966.65)
-- 10- toys(471286.48)
SELECT	t.product_category_1 AS category,
		ROUND(SUM(i.price), 2) AS revenue      
FROM olist_order_items_dataset i
JOIN olist_orders_dataset o USING(order_id)
JOIN olist_products_dataset p USING(product_id)
LEFT JOIN product_category_name_translation t USING(product_category)
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

--- Revenue by state
-- Results:
-- 1 - SP(5067633.16)
-- 2 - RJ(1759651.13)
-- 3 - MG(1552481.83)
SELECT	c.customer_state,
		ROUND(SUM(i.price), 2) AS revenue,
        COUNT(DISTINCT o.order_id) AS orders
FROM olist_order_items_dataset i
JOIN olist_orders_dataset o USING(order_id)
JOIN olist_customers_dataset c USING(customer_id)
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;

--- Average review_score by category
-- Results:
-- 1 - books_general_interest(4.45)
-- 2 - costruction_tools_tools(4.44)
-- 3 - books_imported(4.44)
SELECT	t.product_category_1 AS category,
		ROUND(AVG(review_score), 2) AS avg_score,
        COUNT(*) AS reviews
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset i USING(order_id)
JOIN olist_products_dataset p USING(product_id)
LEFT JOIN product_category_name_translation t USING(product_category)
GROUP BY category
HAVING reviews > 50
ORDER BY  avg_score DESC;

--- Average of delivery time
-- Results: 12.6
SELECT 
		ROUND(AVG(julianday(order_delivered_6) - julianday(order_purchase_t)), 1) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered' And order_delivered_6 IS NOT NULL

--- Distribution of payments methods
-- Results: 
-- 1 - credit_card(76795)
-- 2 - boleto(19784)
-- 3 - voucher(5775)
-- 4 - debit_card(1529)
-- not_defined (3)
SELECT	payment_type,
		COUNT(*) AS n,
        ROUND(SUM(payment_value), 2) AS total_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY n DESC
