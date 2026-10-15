-- 5. Клиенты и рынки

-- Топ-20 клиентов по выручке
SELECT
    "Order Customer Id" AS customer_id,
    COUNT(DISTINCT "Order Id") AS orders,
    ROUND(SUM(NULLIF("Sales"::text, '')::numeric), 2) AS sales,
    ROUND(SUM(
        NULLIF("Sales"::text, '')::numeric *
        NULLIF("Order Item Profit Ratio"::text, '')::numeric
    ), 2) AS estimated_profit
FROM raw.datacosupplychaindataset
GROUP BY "Order Customer Id"
ORDER BY sales DESC NULLS LAST
LIMIT 20;

-- Доля выручки крупнейших клиентов
WITH customer_sales AS (
    SELECT
        "Order Customer Id" AS customer_id,
        SUM(NULLIF("Sales"::text, '')::numeric) AS sales
    FROM raw.datacosupplychaindataset
    GROUP BY "Order Customer Id"
),
ranked AS (
    SELECT
        customer_id,
        sales,
        SUM(sales) OVER () AS total_sales,
        SUM(sales) OVER (ORDER BY sales DESC, customer_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
    FROM customer_sales
)
SELECT
    customer_id,
    ROUND(sales, 2) AS customer_sales,
    ROUND(cumulative_sales / NULLIF(total_sales, 0) * 100, 2)
        AS cumulative_sales_share_pct
FROM ranked
ORDER BY sales DESC
LIMIT 30;

-- Показатели по сегментам клиентов
SELECT
    "Customer Segment" AS customer_segment,
    COUNT(DISTINCT "Order Customer Id") AS customers,
    COUNT(DISTINCT "Order Id") AS orders,
    ROUND(SUM(NULLIF("Sales"::text, '')::numeric), 2) AS sales,
    ROUND(SUM(
        NULLIF("Sales"::text, '')::numeric *
        NULLIF("Order Item Profit Ratio"::text, '')::numeric
    ), 2) AS estimated_profit,
    ROUND(
        SUM(NULLIF("Sales"::text, '')::numeric *
            NULLIF("Order Item Profit Ratio"::text, '')::numeric)
        / NULLIF(SUM(NULLIF("Sales"::text, '')::numeric), 0) * 100,
        2
    ) AS estimated_profit_margin_pct
FROM raw.datacosupplychaindataset
GROUP BY "Customer Segment"
ORDER BY sales DESC NULLS LAST;

-- Сравнение рынков
SELECT
    "Market" AS market,
    COUNT(DISTINCT "Order Id") AS orders,
    COUNT(DISTINCT "Order Customer Id") AS customers,
    ROUND(SUM(NULLIF("Sales"::text, '')::numeric), 2) AS sales,
    ROUND(SUM(
        NULLIF("Sales"::text, '')::numeric *
        NULLIF("Order Item Profit Ratio"::text, '')::numeric
    ), 2) AS estimated_profit,
    ROUND(
        SUM(NULLIF("Sales"::text, '')::numeric *
            NULLIF("Order Item Profit Ratio"::text, '')::numeric)
        / NULLIF(SUM(NULLIF("Sales"::text, '')::numeric), 0) * 100,
        2
    ) AS estimated_profit_margin_pct
FROM raw.datacosupplychaindataset
GROUP BY "Market"
ORDER BY estimated_profit DESC NULLS LAST;
