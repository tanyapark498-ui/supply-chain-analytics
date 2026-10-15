-- 01. Изучение датасета
--  Изучение данных
SELECT
    COUNT(*) AS rows_count,
    COUNT(DISTINCT "Order Id") AS orders_count,
    COUNT(DISTINCT "Order Customer Id") AS customers_count,
    MIN(TO_TIMESTAMP("order date (DateOrders)", 'MM/DD/YYYY HH24:MI'))::date AS first_order_date,
    MAX(TO_TIMESTAMP("order date (DateOrders)", 'MM/DD/YYYY HH24:MI'))::date AS last_order_date
FROM raw.datacosupplychaindataset;

-- Поиск пропусков
SELECT
    COUNT(*) FILTER (WHERE NULLIF(TRIM("Order Id"::text), '') IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE NULLIF(TRIM("Order Customer Id"::text), '') IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE NULLIF(TRIM("Sales"::text), '') IS NULL) AS missing_sales,
    COUNT(*) FILTER (WHERE NULLIF(TRIM("Category Name"::text), '') IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE NULLIF(TRIM("Market"::text), '') IS NULL) AS missing_market,
    COUNT(*) FILTER (WHERE NULLIF(TRIM("order date (DateOrders)"::text), '') IS NULL) AS missing_order_date
FROM raw.datacosupplychaindataset;

-- Проверка дубликатов
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT TO_JSONB(t)) AS unique_rows,
    COUNT(*) - COUNT(DISTINCT TO_JSONB(t)) AS exact_duplicate_rows
FROM raw.datacosupplychaindataset AS t;
