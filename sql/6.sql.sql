-- 6. Статусы заказов и проверка среднего заказа

-- Заказы по статусам
SELECT
    "Order Status" AS order_status,
    COUNT(DISTINCT "Order Id") AS orders,
    ROUND(SUM(NULLIF("Sales"::text, '')::numeric), 2) AS sales
FROM raw.datacosupplychaindataset
GROUP BY "Order Status"
ORDER BY orders DESC;

-- Размер заказа и число товарных строк
WITH order_totals AS (
    SELECT
        "Order Id" AS order_id,
        SUM(NULLIF("Sales"::text, '')::numeric) AS order_sales,
        COUNT(*) AS order_lines,
        SUM(NULLIF("Order Item Quantity"::text, '')::numeric) AS units
    FROM raw.datacosupplychaindataset
    GROUP BY "Order Id"
)
SELECT
    COUNT(*) AS orders,
    ROUND(AVG(order_sales), 2) AS avg_order_sales,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_sales)::numeric, 2)
        AS median_order_sales,
    ROUND(MIN(order_sales), 2) AS min_order_sales,
    ROUND(MAX(order_sales), 2) AS max_order_sales,
    ROUND(AVG(order_lines), 2) AS avg_lines_per_order,
    ROUND(AVG(units), 2) AS avg_units_per_order
FROM order_totals;
