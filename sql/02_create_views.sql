-- ============================================================
-- DataCo Supply Chain Analysis
-- Script 02: Create Analytical Views
-- ============================================================
-- Purpose: Restructure the raw order-item dataset into three
--          clean analytical layers to enable accurate KPI
--          calculation at each level of the business.
--
-- Why views? Because the raw data is at item-level, directly
-- running SUM(profit) GROUP BY category overcounts profit by
-- the number of items per order. Views fix this.
-- ============================================================


-- ============================================================
-- VIEW 1: Order-Level Summary
-- Aggregates all items per order into a single row.
-- Use this for: profit analysis, delivery performance, order size
-- ============================================================

DROP VIEW IF EXISTS v_order;

CREATE VIEW v_order AS
SELECT
    Order_Id                                                      AS order_id,
    MIN(order_date_DateOrders)                                    AS order_date,
    MIN(Market)                                                   AS market,
    MIN(Order_Region)                                             AS region,
    MIN(Order_Country)                                            AS order_country,
    COUNT(*)                                                      AS items_per_order,
    SUM(Sales)                                                    AS total_sales,
    SUM(Order_Item_Quantity)                                      AS total_quantity,
    MIN(Order_Profit_Per_Order)                                   AS order_profit,
    -- MIN is correct here: profit is the same value repeated across all items in an order
    MIN(Late_delivery_risk)                                       AS late_delivery_risk,
    MIN(Days_for_shipping_real - Days_for_shipment_scheduled)     AS shipping_delay
FROM dataco
GROUP BY Order_Id;


-- ============================================================
-- VIEW 2: Product / Category Level Summary
-- Aggregates by product and category across all order items.
-- Use this for: category profitability (with allocated profit)
-- ============================================================

DROP VIEW IF EXISTS v_product;

CREATE VIEW v_product AS
SELECT
    Product_Name,
    Category_Name,
    SUM(Sales)                                  AS total_sales,
    SUM(Order_Item_Quantity)                    AS total_quantity,
    SUM(Order_Item_Discount)                    AS total_discount,
    AVG(Order_Item_Profit_Ratio)                AS avg_item_margin
FROM dataco
GROUP BY Product_Name, Category_Name;


-- ============================================================
-- VIEW 3: Customer-Level Summary
-- Aggregates orders and revenue per customer.
-- Use this for: repeat purchase rate, customer value analysis
-- ============================================================

DROP VIEW IF EXISTS v_customer;

CREATE VIEW v_customer AS
SELECT
    Customer_Id,
    Customer_Segment,
    COUNT(DISTINCT Order_Id)    AS number_of_orders,
    SUM(Sales)                  AS total_sales,
    SUM(Order_Item_Quantity)    AS total_quantity
FROM dataco
GROUP BY Customer_Id, Customer_Segment;


-- ============================================================
-- VIEW 4: Item-Level Allocated Profit
-- Distributes order-level profit to each item proportionally
-- by its share of sales within the order.
-- Use this for: accurate category-level profit analysis
-- ============================================================

DROP VIEW IF EXISTS v_item_profit;

CREATE VIEW v_item_profit AS
SELECT
    d.Order_Id,
    d.Category_Name,
    d.Product_Name,
    d.Sales,
    v.order_profit,
    v.total_sales,
    -- Allocated profit = item's share of order sales × total order profit
    (d.Sales * 1.0 / v.total_sales) * v.order_profit   AS allocated_profit
FROM dataco d
JOIN v_order v
    ON d.Order_Id = v.order_id;
