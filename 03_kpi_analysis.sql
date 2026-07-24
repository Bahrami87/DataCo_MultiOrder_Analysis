-- ============================================================
-- DataCo Supply Chain Analysis
-- Script 03: Core KPI Calculations
-- ============================================================
-- Requires: v_order (from 02_create_views.sql)
-- ============================================================


-- 1. Total net profit across all orders
SELECT
    ROUND(SUM(order_profit), 2) AS net_profit
FROM v_order;
-- Result: -£1,750,141.86
-- The company is loss-making overall.


-- 2. Percentage of orders that are loss-making
SELECT
    ROUND(
        COUNT(CASE WHEN order_profit < 0 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS pct_loss_making_orders
FROM v_order;
-- Result: 37.49%
-- Over one third of all orders lose money.


-- 3. Average profit for loss-making vs profitable orders
SELECT
    CASE WHEN order_profit < 0 THEN 'Loss' ELSE 'Profit' END AS order_type,
    ROUND(AVG(order_profit), 2)                               AS avg_profit,
    COUNT(*)                                                  AS number_of_orders
FROM v_order
GROUP BY order_type;
-- Loss avg: -£135.82 | Profit avg: +£38.87
-- Each loss order wipes out ~3.5 profitable ones.


-- 4. Total profit by market (to check if problem is regional)
SELECT
    market,
    ROUND(SUM(order_profit), 2)     AS total_profit,
    COUNT(*)                         AS total_orders
FROM v_order
GROUP BY market
ORDER BY total_profit ASC;
-- All five markets are in the red. This is NOT a regional problem.


-- 5. On-time delivery rate (order level)
SELECT
    ROUND(
        SUM(CASE WHEN late_delivery_risk = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_pct
FROM v_order;
-- Result: 45.18% on-time — delivery performance is poor.


-- 6. Average shipping delay in days
SELECT
    ROUND(AVG(shipping_delay), 3) AS avg_shipping_delay_days
FROM v_order;
-- Result: +0.567 days behind schedule on average.


-- 7. Category-level profit (using allocated profit — avoids double counting)
SELECT
    Category_Name,
    ROUND(SUM(allocated_profit), 2)     AS allocated_profit,
    ROUND(SUM(Sales), 2)                AS total_sales
FROM v_item_profit
GROUP BY Category_Name
ORDER BY allocated_profit ASC;
-- Top loss-making categories: Fishing (-£418K), Cleats (-£251K), Camping & Hiking (-£240K)
