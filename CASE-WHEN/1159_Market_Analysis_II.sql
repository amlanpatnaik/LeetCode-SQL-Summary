-- Solution 1: Window Function, Subquery, Join, CASE WHEN
-- get item_id of the second item (by date) they sold for each user
WITH tb1 AS (
    SELECT seller_id, item_id
    FROM (
        SELECT seller_id, item_id,
            ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY order_date) AS r
        FROM Orders
        ) rank
    WHERE r = 2
)

-- compare the brand of the second item (by date) they sold with their favorite brand for each user
-- if a user sold less than two items, he/she will have no data from tb1, and thus will be assigned 'no'
SELECT u.user_id AS seller_id,
    CASE
        WHEN u.favorite_brand = i.item_brand THEN 'yes'
        ELSE 'no'
    END AS '2nd_item_fav_brand'
FROM Users u
LEFT JOIN tb1
ON u.user_id = tb1.seller_id
LEFT JOIN Items i
ON tb1.item_id = i.item_id;



-- Solution 2: Join, Subquery, CASE WHEN
-- get item_id of the second item (by date) they sold for each user (having only two sales records on or before o1.order_date)
WITH tb1 AS (
    SELECT o1.seller_id, o1.item_id
    FROM Orders o1
    JOIN orders o2
    ON o1.seller_id = o2.seller_id AND o1.order_date >= o2.order_date
    GROUP BY o1.seller_id, o1.order_date, o1.item_id
    HAVING COUNT(*) = 2
)

-- compare the brand of the second item (by date) they sold with their favorite brand for each user
-- if a user sold less than two items, he/she will have no data from tb1, and thus will be assigned 'no'
SELECT u.user_id AS seller_id,
    CASE
        WHEN u.favorite_brand = i.item_brand THEN 'yes'
        ELSE 'no'
    END AS '2nd_item_fav_brand'
FROM Users u
LEFT JOIN tb1
ON u.user_id = tb1.seller_id
LEFT JOIN Items i
ON tb1.item_id = i.item_id;


--solution 3:
--To solve this problem, we'll follow these steps:

--Join Tables: Join the Orders and Items tables to get the brand information for each order.
--Filter by Seller: Focus on the orders where the user is the seller.
--Rank Orders by Date: Use a window function to rank the items sold by each seller by date.
--Find the Second Sale: Filter to get only the second item sold by each user.
--Check Favorite Brand: Compare the brand of the second item sold to the user's favorite brand.
--Handle Users with Less Than Two Sales: Include all users and handle those who sold fewer than two items.
--Here is the SQL query that implements these steps:

WITH RankedSales AS (
    SELECT
        o.seller_id,
        o.order_date,
        i.item_brand,
        ROW_NUMBER() OVER (PARTITION BY o.seller_id ORDER BY o.order_date) AS sale_rank
    FROM
        Orders o
        JOIN Items i ON o.item_id = i.item_id
),
SecondSales AS (
    SELECT
        rs.seller_id,
        rs.item_brand AS second_item_brand
    FROM
        RankedSales rs
    WHERE
        rs.sale_rank = 2
),
UserSales AS (
    SELECT
        u.user_id,
        u.favorite_brand,
        COALESCE(ss.second_item_brand, 'No') AS second_item_brand
    FROM
        Users u
        LEFT JOIN SecondSales ss ON u.user_id = ss.seller_id
)
SELECT
    us.user_id,
    CASE
        WHEN us.second_item_brand = 'No' THEN 'No'
        WHEN us.favorite_brand = us.second_item_brand THEN 'Yes'
        ELSE 'No'
    END AS is_favorite
FROM
    UserSales us;

