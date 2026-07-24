-- ============================================================
-- DataCo Supply Chain Analysis
-- Script 01: Data Audit & Initial Validation
-- ============================================================
-- Purpose: Understand the dataset structure and quality before
--          any KPI calculation. This step is critical to avoid
--          double-counting profit at the order-item level.
-- ============================================================

-- 1. How many distinct orders are there?
SELECT COUNT(DISTINCT Order_Id) AS total_orders
FROM dataco;
-- Result: 65,752

-- 2. How many order-item rows are there?
SELECT COUNT(*) AS total_rows
FROM dataco;
-- Result: 180,519
-- Note: Each order has multiple rows (items). Profit must be aggregated carefully.

-- 3. Verify that Order_Profit_Per_Order is repeated across items in the same order
--    (not summed). If row_count > 1 and profit looks inflated, it confirms repetition.
SELECT
    Order_Id,
    COUNT(*) AS row_count,
    SUM(Order_Profit_Per_Order) AS raw_sum_profit,
    MIN(Order_Profit_Per_Order) AS actual_order_profit
FROM dataco
GROUP BY Order_Id
HAVING COUNT(*) > 1
LIMIT 10;
-- Key insight: MIN() = actual profit; SUM() is inflated by item count.
-- Always use MIN(Order_Profit_Per_Order) at order level.

-- 4. How many orders have negative profit?
SELECT COUNT(DISTINCT Order_Id) AS loss_making_orders
FROM dataco
WHERE Order_Profit_Per_Order < 0;
-- Result: 24,649

-- 5. What is the overall late delivery risk rate?
SELECT
    ROUND(
        SUM(CASE WHEN Late_delivery_risk = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_pct
FROM dataco;
-- Result: 54.83% — over half of all order-items carry late delivery risk

-- 6. What is the average difference between actual and scheduled shipping days?
SELECT
    ROUND(
        AVG(Days_for_shipping_real - Days_for_shipment_scheduled),
        3
    ) AS avg_shipping_delay_days
FROM dataco;
-- Result: +0.566 days — shipments are consistently late vs schedule

-- 7. What discount rates are being applied?
SELECT
    ROUND(AVG(Order_Item_Discount_Rate), 4) AS avg_discount_rate,
    ROUND(MAX(Order_Item_Discount_Rate), 4) AS max_discount_rate
FROM dataco;
-- Result: Avg = 10.2%, Max = 25%
-- Interpretation: Discounts are moderate — unlikely to be the primary driver of losses
