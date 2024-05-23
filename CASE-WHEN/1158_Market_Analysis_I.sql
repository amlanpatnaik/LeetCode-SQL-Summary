SELECT u.user_id AS buyer_id, u.join_date AS join_date,
    SUM(CASE WHEN YEAR(order_date) = 2019 THEN 1 ELSE 0 END) AS orders_in_2019
FROM Users u
LEFT JOIN Orders o
ON u.user_id = o.buyer_id
GROUP BY u.user_id, u.join_date;

# Solution-2


SELECT u.user_id AS buyer_id,
       u.join_date,
       IFNULL(o.orders_in_2019, 0) AS orders_in_2019
FROM users u
LEFT JOIN
    (SELECT buyer_id,
        COUNT(order_id) AS orders_in_2019
    FROM orders
    WHERE YEAR(order_date) = 2019
    GROUP BY 1) AS o
ON u.user_id = o.buyer_id 

