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
