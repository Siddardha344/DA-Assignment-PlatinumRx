Section B: SQL – Clinic Management System
1. Revenue from each sales channel in a given year
SELECT 
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = :given_year   -- replace :given_year with target year
GROUP BY sales_channel
ORDER BY total_revenue DESC;

2. Top 10 most valuable customers in a given year
SELECT 
    c.uid,
    c.name,
    c.mobile,
    SUM(cs.amount) AS total_spend
FROM clinic_sales cs
JOIN customer c ON cs.uid = c.uid
WHERE YEAR(cs.datetime) = :given_year
GROUP BY c.uid, c.name, c.mobile
ORDER BY total_spend DESC
LIMIT 10;

3. Month-wise revenue, expense, profit, and profitability status
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(datetime, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = :given_year
    GROUP BY month
),
monthly_expense AS (
    SELECT 
        DATE_FORMAT(datetime, '%Y-%m') AS month,
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = :given_year
    GROUP BY month
)
SELECT 
    COALESCE(r.month, e.month)          AS month,
    COALESCE(r.revenue, 0)              AS revenue,
    COALESCE(e.expense, 0)              AS expense,
    COALESCE(r.revenue, 0) - COALESCE(e.expense, 0) AS profit,
    CASE 
        WHEN COALESCE(r.revenue, 0) - COALESCE(e.expense, 0) >= 0 
        THEN 'Profitable' 
        ELSE 'Not-Profitable' 
    END AS status
FROM monthly_revenue r
FULL OUTER JOIN monthly_expense e ON r.month = e.month
ORDER BY month;

4. Most profitable clinic per city for a given month
WITH clinic_profit AS (
    SELECT 
        cl.cid,
        cl.clinic_name,
        cl.city,
        COALESCE(SUM(cs.amount), 0) - COALESCE(SUM(ex.amount), 0) AS profit
    FROM clinics cl
    LEFT JOIN clinic_sales cs 
        ON cl.cid = cs.cid 
        AND DATE_FORMAT(cs.datetime, '%Y-%m') = :given_month
    LEFT JOIN expenses ex 
        ON cl.cid = ex.cid 
        AND DATE_FORMAT(ex.datetime, '%Y-%m') = :given_month
    GROUP BY cl.cid, cl.clinic_name, cl.city
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM clinic_profit
)
SELECT city, cid, clinic_name, profit
FROM ranked
WHERE rnk = 1;

5. Second least profitable clinic per state for a given month
WITH clinic_profit AS (
    SELECT 
        cl.cid,
        cl.clinic_name,
        cl.state,
        COALESCE(SUM(cs.amount), 0) - COALESCE(SUM(ex.amount), 0) AS profit
    FROM clinics cl
    LEFT JOIN clinic_sales cs 
        ON cl.cid = cs.cid 
        AND DATE_FORMAT(cs.datetime, '%Y-%m') = :given_month
    LEFT JOIN expenses ex 
        ON cl.cid = ex.cid 
        AND DATE_FORMAT(ex.datetime, '%Y-%m') = :given_month
    GROUP BY cl.cid, cl.clinic_name, cl.state
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM clinic_profit
)
SELECT state, cid, clinic_name, profit
FROM ranked
WHERE rnk = 2;
