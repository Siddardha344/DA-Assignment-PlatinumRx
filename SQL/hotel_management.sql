Section A: SQL – Hotel Management System
1. Last booked room_no for every user
SELECT u.user_id, b.room_no
FROM users u
JOIN bookings b ON u.user_id = b.user_id
WHERE b.booking_date = (
    SELECT MAX(b2.booking_date)
    FROM bookings b2
    WHERE b2.user_id = u.user_id
);

2. Booking_id and total billing amount for bookings in November 2021
SELECT 
    bc.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_billing_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
JOIN bookings b ON bc.booking_id = b.booking_id
WHERE DATE_FORMAT(b.booking_date, '%Y-%m') = '2021-11'
GROUP BY bc.booking_id;

3. Bill_id and bill amount for October 2021 with bill amount > 1000
SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-10'
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

4. Most and least ordered item of each month in 2021
WITH monthly_orders AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        i.item_name,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, i.item_name
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS rk_most,
        RANK() OVER (PARTITION BY month ORDER BY total_qty ASC)  AS rk_least
    FROM monthly_orders
)
SELECT 
    month,
    MAX(CASE WHEN rk_most  = 1 THEN item_name END) AS most_ordered_item,
    MAX(CASE WHEN rk_least = 1 THEN item_name END) AS least_ordered_item
FROM ranked
WHERE rk_most = 1 OR rk_least = 1
GROUP BY month
ORDER BY month;	

5. Customers with the second highest bill value each month in 2021
WITH bill_totals AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        b.user_id,
        SUM(bc.item_quantity * i.item_rate) AS bill_value
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    JOIN bookings b ON bc.booking_id = b.booking_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, b.user_id
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY month ORDER BY bill_value DESC) AS rnk
    FROM bill_totals
)
SELECT 
    r.month,
    u.user_id,
    u.name,
    r.bill_value
FROM ranked r
JOIN users u ON r.user_id = u.user_id
WHERE r.rnk = 2
ORDER BY r.month;
