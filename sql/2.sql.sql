-- 2. Основные показатели и динамика


-- Основные показатели. Оценка прибыли через продажи и долю прибыли.
SELECT
    COUNT(DISTINCT "Order Id") AS orders,
    COUNT(DISTINCT "Order Customer Id") AS customers,
    ROUND(SUM(NULLIF("Sales"::text, '')::numeric), 2) AS total_sales,
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
FROM raw.datacosupplychaindataset;

-- Продажи и прибыль по месяцам
WITH monthly AS (
    SELECT
        DATE_TRUNC(
            'month',
            TO_TIMESTAMP("order date (DateOrders)", 'MM/DD/YYYY HH24:MI')
        )::date AS month,
        SUM(NULLIF("Sales"::text, '')::numeric) AS sales,
        SUM(
            NULLIF("Sales"::text, '')::numeric *
            NULLIF("Order Item Profit Ratio"::text, '')::numeric
        ) AS estimated_profit
    FROM raw.datacosupplychaindataset
    GROUP BY 1
)
SELECT
    month,
    ROUND(sales, 2) AS sales,
    ROUND(estimated_profit, 2) AS estimated_profit
FROM monthly
ORDER BY month;

-- Изменение продаж к прошлому месяцу
WITH monthly AS (
    SELECT
        DATE_TRUNC(
            'month',
            TO_TIMESTAMP("order date (DateOrders)", 'MM/DD/YYYY HH24:MI')
        )::date AS month,
        SUM(NULLIF("Sales"::text, '')::numeric) AS sales
    FROM raw.datacosupplychaindataset
    GROUP BY 1
),
with_previous AS (
    SELECT
        month,
        sales,
        LAG(sales) OVER (ORDER BY month) AS previous_month_sales
    FROM monthly
)
SELECT
    month,
    ROUND(sales, 2) AS sales,
    ROUND(previous_month_sales, 2) AS previous_month_sales,
    ROUND((sales - previous_month_sales) / NULLIF(previous_month_sales, 0) * 100, 2)
        AS sales_growth_pct
FROM with_previous
ORDER BY month;

