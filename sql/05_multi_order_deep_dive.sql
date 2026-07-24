-- ============================================================
-- DataCo Supply Chain Analysis
-- Script 05: Multi-Item Order Deep Dive
-- ============================================================
-- This script identifies and proves the structural profit problem
-- in multi-item orders — the core finding of this project.
-- ============================================================


-- 1. Compare Single vs Multi-item orders: volume, revenue, profit
SELECT
    CASE WHEN items_per_order = 1 THEN 'Single-Item' ELSE 'Multi-Item' END AS order_type,
    COUNT(*)                                AS order_count,
    ROUND(SUM(total_sales), 2)             AS total_revenue,
    ROUND(SUM(order_profit), 2)            AS total_profit,
    ROUND(AVG(order_profit), 2)            AS avg_profit_per_order
FROM v_order
GROUP BY order_type;

-- Result:
--   Multi-Item:  45,902 orders | £32.0M revenue | -£2.30M profit | avg -£50.00/order
--   Single-Item: 19,850 orders |  £4.7M revenue | +£545K profit  | avg +£27.46/order
--
-- KEY FINDING:
--   87% of revenue comes from multi-item orders.
--   Multi-item orders systematically lose money.
--   Single-item orders are the ONLY source of company profit.


-- 2. Profit by number of items — does it decline linearly?
SELECT
    items_per_order,
    ROUND(AVG(order_profit), 2)    AS avg_profit,
    ROUND(AVG(total_sales), 2)     AS avg_revenue,
    ROUND(AVG(total_quantity), 2)  AS avg_quantity,
    COUNT(*)                        AS order_count
FROM v_order
GROUP BY items_per_order
ORDER BY items_per_order;

-- Result:
--   1 item  → +£27.46 avg profit   | £240 revenue
--   2 items → -£17.97 avg profit   | £400 revenue
--   3 items → -£42.71 avg profit   | £596 revenue
--   4 items → -£60.11 avg profit   | £796 revenue
--   5 items → -£79.21 avg profit   | £998 revenue
--
-- Revenue grows linearly (~+£240 per item added).
-- Profit declines linearly (~-£20 to -£22 per item added).
-- This is the signature of a hidden per-item cost that is not
-- priced into the product.


-- 3. Does late delivery explain the multi-item loss?
SELECT
    CASE WHEN items_per_order = 1 THEN 'Single-Item' ELSE 'Multi-Item' END AS order_type,
    ROUND(AVG(late_delivery_risk) * 100, 2) AS late_delivery_pct
FROM v_order
GROUP BY order_type;

-- Result: Multi 54.7% | Single 55.1% — virtually identical.
-- ❌ Late delivery does NOT explain multi-item losses.


-- 4. Does discount explain the multi-item loss?
SELECT
    v.items_per_order,
    ROUND(AVG(d.Order_Item_Discount_Rate), 5) AS avg_discount_rate
FROM dataco d
JOIN v_order v ON d.Order_Id = v.order_id
GROUP BY v.items_per_order
ORDER BY v.items_per_order;

-- Result: All item counts show ~10.15–10.18% discount. Completely flat.
-- ❌ Discount does NOT explain multi-item losses.


-- 5. Is the multi-item problem consistent across all markets?
SELECT
    market,
    items_per_order,
    ROUND(AVG(order_profit), 2)    AS avg_profit,
    COUNT(*)                        AS order_count
FROM v_order
GROUP BY market, items_per_order
ORDER BY market, items_per_order;

-- Result: Every market shows the same pattern.
--   Africa:       1 item +£24.85 → 5 items -£75.87
--   Europe:       1 item +£34.08 → 5 items -£80.38
--   LATAM:        1 item +£23.11 → 5 items -£77.91
--   Pacific Asia: 1 item +£25.67 → 5 items -£81.52
--   USCA:         1 item +£23.12 → 5 items -£77.94
--
-- ❌ This is NOT a regional problem. The pattern is universal.
-- ✅ CONCLUSION: This is a structural flaw in multi-item order economics.


-- 6. Summary: Profit contribution by segment
-- This is the key business metric to present to stakeholders.
SELECT
    CASE WHEN items_per_order = 1 THEN 'Single-Item' ELSE 'Multi-Item' END  AS segment,
    COUNT(*)                                AS orders,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM v_order), 1) AS pct_of_orders,
    ROUND(SUM(total_sales), 0)             AS revenue,
    ROUND(SUM(total_sales) * 100.0 /
        (SELECT SUM(total_sales) FROM v_order), 1) AS pct_of_revenue,
    ROUND(SUM(order_profit), 0)            AS profit
FROM v_order
GROUP BY segment;
