-- 3. Товары и категории

-- Показатели по категориям
SELECT
    "Category Name" AS category,
    COUNT(DISTINCT "Order Id") AS orders,
    ROUND(SUM(NULLIF("Sales"::text, '')::numeric), 2) AS sales,
    ROUND(SUM(
        NULLIF("Sales"::text, '')::numeric *
        NULLIF("Order Item Profit Ratio"::text, '')::numeric
    ), 2) AS estimated_profit,
    ROUND(AVG(NULLIF("Order Item Profit Ratio"::text, '')::numeric) * 100, 2)
        AS avg_line_profit_ratio_pct
FROM raw.datacosupplychaindataset
GROUP BY "Category Name"
ORDER BY estimated_profit DESC NULLS LAST;

-- Топ-15 товаров по выручке
SELECT
    "Product Name" AS product,
    COUNT(DISTINCT "Order Id") AS orders,
    SUM(NULLIF("Order Item Quantity"::text, '')::numeric) AS units_sold,
    ROUND(SUM(NULLIF("Sales"::text, '')::numeric), 2) AS sales,
    ROUND(SUM(
        NULLIF("Sales"::text, '')::numeric *
        NULLIF("Order Item Profit Ratio"::text, '')::numeric
    ), 2) AS estimated_profit
FROM raw.datacosupplychaindataset
GROUP BY "Product Name"
ORDER BY sales DESC NULLS LAST
LIMIT 15;

-- Скидки и прибыльность
SELECT
    CASE
        WHEN NULLIF("Order Item Discount Rate"::text, '')::numeric < 0.05 THEN '0–5%'
        WHEN NULLIF("Order Item Discount Rate"::text, '')::numeric < 0.10 THEN '5–10%'
        WHEN NULLIF("Order Item Discount Rate"::text, '')::numeric < 0.20 THEN '10–20%'
        ELSE '20%+'
    END AS discount_band,
    COUNT(*) AS order_lines,
    ROUND(AVG(NULLIF("Order Item Discount Rate"::text, '')::numeric) * 100, 2)
        AS avg_discount_pct,
    ROUND(SUM(NULLIF("Sales"::text, '')::numeric), 2) AS sales,
    ROUND(SUM(
        NULLIF("Sales"::text, '')::numeric *
        NULLIF("Order Item Profit Ratio"::text, '')::numeric
    ), 2) AS estimated_profit,
    ROUND(AVG(NULLIF("Order Item Profit Ratio"::text, '')::numeric) * 100, 2)
        AS avg_line_profit_ratio_pct
FROM raw.datacosupplychaindataset
GROUP BY 1
ORDER BY MIN(NULLIF("Order Item Discount Rate"::text, '')::numeric);

