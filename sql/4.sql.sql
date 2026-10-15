-- 4. Доставка

-- Доставка по способам отправки
SELECT
    "Shipping Mode" AS shipping_mode,
    COUNT(*) AS order_lines,
    ROUND(AVG(NULLIF("Days for shipping (real)"::text, '')::numeric), 2)
        AS avg_actual_shipping_days,
    ROUND(AVG(NULLIF("Days for shipment (scheduled)"::text, '')::numeric), 2)
        AS avg_scheduled_shipping_days,
    ROUND(AVG(
        NULLIF("Days for shipping (real)"::text, '')::numeric -
        NULLIF("Days for shipment (scheduled)"::text, '')::numeric
    ), 2) AS avg_days_vs_schedule,
    ROUND(AVG(NULLIF("Late_delivery_risk"::text, '')::numeric) * 100, 2)
        AS late_delivery_risk_pct
FROM raw.datacosupplychaindataset
GROUP BY "Shipping Mode"
ORDER BY avg_days_vs_schedule DESC NULLS LAST;

-- Риск опоздания
SELECT
    "Late_delivery_risk" AS late_delivery_risk,
    COUNT(*) AS order_lines,
    COUNT(DISTINCT "Order Id") AS orders,
    ROUND(AVG(
        NULLIF("Days for shipping (real)"::text, '')::numeric -
        NULLIF("Days for shipment (scheduled)"::text, '')::numeric
    ), 2) AS avg_days_vs_schedule
FROM raw.datacosupplychaindataset
GROUP BY "Late_delivery_risk"
ORDER BY "Late_delivery_risk";

-- Доставка по рынкам
SELECT
    "Market" AS market,
    COUNT(DISTINCT "Order Id") AS orders,
    ROUND(AVG(
        NULLIF("Days for shipping (real)"::text, '')::numeric
    ), 2) AS avg_actual_shipping_days,
    ROUND(AVG(
        NULLIF("Days for shipping (real)"::text, '')::numeric -
        NULLIF("Days for shipment (scheduled)"::text, '')::numeric
    ), 2) AS avg_days_vs_schedule,
    ROUND(AVG(NULLIF("Late_delivery_risk"::text, '')::numeric) * 100, 2)
        AS late_delivery_risk_pct
FROM raw.datacosupplychaindataset
GROUP BY "Market"
ORDER BY late_delivery_risk_pct DESC NULLS LAST;

-- Регионы с большими задержками
SELECT
    "Order Region" AS order_region,
    COUNT(DISTINCT "Order Id") AS orders,
    ROUND(AVG(
        NULLIF("Days for shipping (real)"::text, '')::numeric -
        NULLIF("Days for shipment (scheduled)"::text, '')::numeric
    ), 2) AS avg_days_vs_schedule,
    ROUND(AVG(NULLIF("Late_delivery_risk"::text, '')::numeric) * 100, 2)
        AS late_delivery_risk_pct
FROM raw.datacosupplychaindataset
GROUP BY "Order Region"
HAVING COUNT(*) >= 100
ORDER BY avg_days_vs_schedule DESC NULLS LAST
LIMIT 15;

