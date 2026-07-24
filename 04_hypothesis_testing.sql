-- ============================================================
-- DataCo Supply Chain Analysis
-- Script 04: Hypothesis Testing
-- ============================================================
-- Three hypotheses are tested to explain the structural losses:
--   H1: Discounts are the primary driver of losses
--   H2: Late delivery is the primary driver of losses
--   H3: Certain product categories are causing losses
-- ============================================================


-- ============================================================
-- HYPOTHESIS 1: Are discounts causing loss-making orders?
-- ============================================================

SELECT
    CASE WHEN Order_Profit_Per_Order < 0 THEN 'Loss' ELSE 'Profit' END AS order_type,
    ROUND(AVG(Order_Item_Discount_Rate), 5)                            AS avg_discount_rate
FROM dataco
GROUP BY order_type;

-- Result:
--   Loss   → 10.22%
--   Profit → 10.15%
--
-- ❌ HYPOTHESIS REJECTED
-- The difference is negligible (<0.1%). Discount policy is not
-- meaningfully different between loss and profit orders.


-- ============================================================
-- HYPOTHESIS 2: Does late delivery drive lower profit?
-- ============================================================

SELECT
    CASE WHEN late_delivery_risk = 1 THEN 'Late' ELSE 'On Time' END AS delivery_type,
    ROUND(AVG(order_profit), 2)                                      AS avg_order_profit,
    COUNT(*)                                                          AS order_count
FROM v_order
GROUP BY delivery_type;

-- Compare late vs on-time avg profit — if similar, delivery is not the cause.
-- ❌ HYPOTHESIS REJECTED
-- Late and on-time orders have nearly identical average profit levels.


-- ============================================================
-- HYPOTHESIS 3: Are specific categories the root cause?
-- ============================================================

-- Using allocated profit to avoid item-level double counting
SELECT
    Category_Name,
    ROUND(SUM(allocated_profit), 2)     AS real_allocated_profit,
    ROUND(AVG(allocated_profit), 4)     AS avg_profit_per_item
FROM v_item_profit
GROUP BY Category_Name
ORDER BY real_allocated_profit ASC
LIMIT 10;

-- Result (top 10 worst categories):
--   Fishing              -£418,054
--   Cleats               -£251,499
--   Camping & Hiking     -£240,263
--   Cardio Equipment     -£228,230
--   Women's Apparel      -£184,478
--   Water Sports         -£180,390
--   Indoor/Outdoor Games -£167,385
--   Men's Footwear       -£165,424
--   Shop By Sport         -£79,644
--   Electronics           -£21,232
--
-- ✅ HYPOTHESIS CONFIRMED (partially)
-- Several categories are heavily loss-making. However, this alone
-- does not explain WHY — the item margins are positive for these
-- categories. Something at the ORDER level is absorbing profit.
-- → This leads to the multi-item order deep dive (Script 05).


-- ============================================================
-- Additional check: Are item-level margins actually negative?
-- ============================================================

SELECT
    ROUND(MIN(Order_Item_Profit_Ratio), 4)  AS min_item_margin,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)  AS avg_item_margin,
    ROUND(MAX(Order_Item_Profit_Ratio), 4)  AS max_item_margin
FROM dataco;

-- If avg item margin is positive but orders are still losing money,
-- the cost driver is outside of per-item pricing.
-- This points to ORDER-LEVEL costs (fulfilment, handling, shipping).
