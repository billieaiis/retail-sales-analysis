USE portfolio_1;

DESCRIBE transaction_data;

#Periksa Missing values
SELECT
    COUNT(*) AS total_records,
    SUM(household_key IS NULL) AS missing_household,
    SUM(BASKET_ID IS NULL) AS missing_basket,
    SUM(DAY IS NULL) AS missing_day,
    SUM(PRODUCT_ID IS NULL) AS missing_product,
    SUM(QUANTITY IS NULL) AS missing_quantity,
    SUM(SALES_VALUE IS NULL) AS missing_sales,
    SUM(STORE_ID IS NULL) AS missing_store,
    SUM(RETAIL_DISC IS NULL) AS missing_retail_disc,
    SUM(TRANS_TIME IS NULL) AS missing_trans_time,
    SUM(WEEK_NO IS NULL) AS missing_week
FROM transaction_data;

#Memeriksa nilai Minimum dan Maksimum
SELECT
    MIN(DAY) AS min_day,
    MAX(DAY) AS max_day,
    MIN(WEEK_NO) AS min_week,
    MAX(WEEK_NO) AS max_week,
    MIN(QUANTITY) AS min_quantity,
    MAX(QUANTITY) AS max_quantity,
    MIN(SALES_VALUE) AS min_sales,
    MAX(SALES_VALUE) AS max_sales,
    MIN(TRANS_TIME) AS min_trans_time,
    MAX(TRANS_TIME) AS max_trans_time
FROM transaction_data;

#Memeriksa Nilai Coupon
SELECT
    MIN(COUPON_DISC) AS min_coupon_disc,
    MAX(COUPON_DISC) AS max_coupon_disc,
    MIN(COUPON_MATCH_DISC) AS min_coupon_match_disc,
    MAX(COUPON_MATCH_DISC) AS max_coupon_match_disc
FROM transaction_data;

#2. Langkah berikutnya: pemeriksaan nilai tidak wajar
# Distribusi nilai nol dan negatif
SELECT
    SUM(QUANTITY = 0) AS zero_quantity,
    SUM(QUANTITY < 0) AS negative_quantity,
    SUM(SALES_VALUE = 0) AS zero_sales,
    SUM(SALES_VALUE < 0) AS negative_sales,
    SUM(RETAIL_DISC < 0) AS negative_retail_disc,
    SUM(COUPON_DISC < 0) AS negative_coupon_disc,
    SUM(COUPON_MATCH_DISC < 0) AS negative_coupon_match_disc
FROM transaction_data;

#Periksa transaksi dengan kuantitas sangat besar
SELECT
    household_key,
    BASKET_ID,
    DAY,
    PRODUCT_ID,
    QUANTITY,
    SALES_VALUE,
    STORE_ID
FROM transaction_data
WHERE QUANTITY >= 1000
ORDER BY QUANTITY DESC
LIMIT 20;

#Periksa distribusi kuantitas
SELECT
    QUANTITY,
    COUNT(*) AS total_records
FROM transaction_data
GROUP BY QUANTITY
ORDER BY QUANTITY DESC
LIMIT 20;

#3.EDA
#1. Periksa hubungan zero quantity dan zero sales
SELECT
    CASE
        WHEN QUANTITY = 0 AND SALES_VALUE = 0
            THEN 'Zero Quantity & Zero Sales'
        WHEN QUANTITY = 0 AND SALES_VALUE > 0
            THEN 'Zero Quantity & Positive Sales'
        WHEN QUANTITY > 0 AND SALES_VALUE = 0
            THEN 'Positive Quantity & Zero Sales'
        WHEN QUANTITY > 0 AND SALES_VALUE > 0
            THEN 'Positive Quantity & Positive Sales'
    END AS transaction_condition,
    COUNT(*) AS total_records
FROM transaction_data
GROUP BY transaction_condition
ORDER BY total_records DESC;

#Periksa produk dengan quantity ekstrem
SELECT
    PRODUCT_ID,
    COUNT(*) AS total_records,
    COUNT(DISTINCT BASKET_ID) AS unique_baskets,
    COUNT(DISTINCT household_key) AS unique_households,
    MIN(QUANTITY) AS min_quantity,
    MAX(QUANTITY) AS max_quantity,
    AVG(QUANTITY) AS avg_quantity,
    SUM(QUANTITY) AS total_quantity,
    SUM(SALES_VALUE) AS total_sales
FROM transaction_data
WHERE PRODUCT_ID IN (6534178, 6544236, 6534166)
GROUP BY PRODUCT_ID
ORDER BY total_quantity DESC;

#Memeriksa Sampel Transaksi
SELECT
    PRODUCT_ID,
    BASKET_ID,
    household_key,
    QUANTITY,
    SALES_VALUE,
    ROUND(SALES_VALUE / NULLIF(QUANTITY, 0), 6)
        AS effective_price
FROM transaction_data
WHERE PRODUCT_ID IN (6534178, 6544236, 6534166)
ORDER BY QUANTITY DESC
LIMIT 20;

# Memeriksa distribusi Quantity secara keseluruhan
SELECT
    CASE
        WHEN QUANTITY = 0 THEN 'Zero'
        WHEN QUANTITY BETWEEN 1 AND 10 THEN '1–10'
        WHEN QUANTITY BETWEEN 11 AND 100 THEN '11–100'
        WHEN QUANTITY BETWEEN 101 AND 1000 THEN '101–1,000'
        WHEN QUANTITY BETWEEN 1001 AND 10000 THEN '1,001–10,000'
        WHEN QUANTITY > 10000 THEN '>10,000'
    END AS quantity_range,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transaction_data),
        2
    ) AS percentage
FROM transaction_data
GROUP BY quantity_range
ORDER BY MIN(QUANTITY);

SELECT
    COUNT(*) AS total_records,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    SUM(QUANTITY) AS total_quantity,
    COUNT(DISTINCT BASKET_ID) AS total_baskets,
    COUNT(DISTINCT household_key) AS total_households,
    COUNT(DISTINCT PRODUCT_ID) AS total_products
FROM transaction_data;

#Analis Tren Penjualan
CREATE OR REPLACE VIEW vw_sales_by_week AS
SELECT
    WEEK_NO,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    SUM(QUANTITY) AS total_quantity,
    COUNT(DISTINCT BASKET_ID) AS total_baskets,
    COUNT(DISTINCT household_key) AS total_households
FROM transaction_data
WHERE SALES_VALUE > 0
GROUP BY WEEK_NO
ORDER BY WEEK_NO;

SELECT *
FROM vw_sales_by_week
ORDER BY WEEK_NO;

#Validasi dan ranking mingguan
#lima minggu dengan penjualan tertinggi:
SELECT *
FROM vw_sales_by_week
ORDER BY total_sales DESC
LIMIT 5;

#lima minggu dengan penjualan terendah:
SELECT *
FROM vw_sales_by_week
ORDER BY total_sales ASC
LIMIT 5;

#Validasi penjualan dari view
SELECT
    ROUND(SUM(total_sales), 2) AS weekly_sales_total
FROM vw_sales_by_week;


#analisis performa produk
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    PRODUCT_ID,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    SUM(QUANTITY) AS total_quantity,
    COUNT(DISTINCT BASKET_ID) AS total_baskets,
    COUNT(DISTINCT household_key) AS total_households
FROM transaction_data
WHERE SALES_VALUE > 0
GROUP BY PRODUCT_ID;

SELECT
    PRODUCT_ID,
    total_sales,
    total_quantity,
    total_baskets,
    total_households
FROM vw_product_performance
ORDER BY total_sales DESC
LIMIT 10;

#Membandingkan sales ddengan frekuensi Pembelian 
SELECT
    PRODUCT_ID,
    total_baskets,
    total_households,
    total_sales,
    total_quantity
FROM vw_product_performance
ORDER BY total_baskets DESC
LIMIT 10;

#Identifikasi Kontribusi Sales
SELECT
    PRODUCT_ID,
    total_sales,
    ROUND(
        total_sales * 100.0 /
        (SELECT SUM(total_sales)
         FROM vw_product_performance),
        2
    ) AS sales_contribution_pct,
    total_baskets,
    total_households
FROM vw_product_performance
ORDER BY total_sales DESC
LIMIT 10;

#Identifikasi nama dan kategori produk
SHOW TABLES;
DESCRIBE product;

# Top 10 produk beserta kategorinya
SELECT
    p.PRODUCT_ID,
    p.BRAND,
    p.DEPARTMENT,
    p.COMMODITY_DESC,
    p.SUB_COMMODITY_DESC,
    p.CURR_SIZE_OF_PRODUCT,
    v.total_sales,
    v.total_quantity,
    v.total_baskets,
    v.total_households
FROM vw_product_performance v
LEFT JOIN product p
    ON v.PRODUCT_ID = p.PRODUCT_ID
ORDER BY v.total_sales DESC
LIMIT 10;

# Analisis sales per department
SELECT
    p.DEPARTMENT,
    ROUND(SUM(t.SALES_VALUE), 2) AS total_sales,
    SUM(t.QUANTITY) AS total_quantity,
    COUNT(DISTINCT t.BASKET_ID) AS total_baskets,
    COUNT(DISTINCT t.household_key) AS total_households
FROM transaction_data t
JOIN product p
    ON t.PRODUCT_ID = p.PRODUCT_ID
WHERE t.SALES_VALUE > 0
GROUP BY p.DEPARTMENT
ORDER BY total_sales DESC;

# Top 10 kategori Grocery:
SELECT
    p.COMMODITY_DESC,
    ROUND(SUM(t.SALES_VALUE), 2) AS total_sales,
    ROUND(
        SUM(t.SALES_VALUE) * 100.0 / 4093814.14,
        2
    ) AS sales_contribution_pct,
    SUM(t.QUANTITY) AS total_quantity,
    COUNT(DISTINCT t.BASKET_ID) AS total_baskets,
    COUNT(DISTINCT t.household_key) AS total_households
FROM transaction_data t
JOIN product p
    ON t.PRODUCT_ID = p.PRODUCT_ID
WHERE
    t.SALES_VALUE > 0
    AND p.DEPARTMENT = 'GROCERY'
GROUP BY p.COMMODITY_DESC
ORDER BY total_sales DESC
LIMIT 10;

#Mendalami kategori soft drink
SELECT
    p.PRODUCT_ID,
    p.BRAND,
    p.SUB_COMMODITY_DESC,
    p.CURR_SIZE_OF_PRODUCT,
    ROUND(SUM(t.SALES_VALUE), 2) AS total_sales,
    SUM(t.QUANTITY) AS total_quantity,
    COUNT(DISTINCT t.BASKET_ID) AS total_baskets,
    COUNT(DISTINCT t.household_key) AS total_households
FROM transaction_data t
JOIN product p
    ON t.PRODUCT_ID = p.PRODUCT_ID
WHERE
    t.SALES_VALUE > 0
    AND p.DEPARTMENT = 'GROCERY'
    AND p.COMMODITY_DESC = 'SOFT DRINKS'
GROUP BY
    p.PRODUCT_ID,
    p.BRAND,
    p.SUB_COMMODITY_DESC,
    p.CURR_SIZE_OF_PRODUCT
ORDER BY total_sales DESC
LIMIT 10;

# Membandingkan performa berdasarkan subkategori Soft Drinks, bukan hanya berdasarkan masing-masing Product ID.
SELECT
    p.SUB_COMMODITY_DESC,
    COUNT(DISTINCT p.PRODUCT_ID) AS total_products,
    ROUND(SUM(t.SALES_VALUE), 2) AS total_sales,
    SUM(t.QUANTITY) AS total_quantity,
    COUNT(DISTINCT t.BASKET_ID) AS total_baskets,
    COUNT(DISTINCT t.household_key) AS total_households
FROM transaction_data t
JOIN product p
    ON t.PRODUCT_ID = p.PRODUCT_ID
WHERE
    t.SALES_VALUE > 0
    AND p.DEPARTMENT = 'GROCERY'
    AND p.COMMODITY_DESC = 'SOFT DRINKS'
GROUP BY p.SUB_COMMODITY_DESC
ORDER BY total_sales DESC;

# Memeriksa apakah hasil agregasi department dan kategori sudah konsisten dengan total sales
SELECT
    ROUND(SUM(total_sales), 2) AS total_soft_drinks_sales
FROM (
    SELECT
        SUM(t.SALES_VALUE) AS total_sales
    FROM transaction_data t
    JOIN product p
        ON t.PRODUCT_ID = p.PRODUCT_ID
    WHERE
        t.SALES_VALUE > 0
        AND p.DEPARTMENT = 'GROCERY'
        AND p.COMMODITY_DESC = 'SOFT DRINKS'
    GROUP BY p.SUB_COMMODITY_DESC
) AS subcategory_sales;

#View Grocery Category Performance.
CREATE OR REPLACE VIEW vw_grocery_category_performance AS
SELECT
    p.COMMODITY_DESC,
    ROUND(SUM(t.SALES_VALUE), 2) AS total_sales,
    SUM(t.QUANTITY) AS total_quantity,
    COUNT(DISTINCT t.BASKET_ID) AS total_baskets,
    COUNT(DISTINCT t.household_key) AS total_households
FROM transaction_data t
JOIN product p
    ON t.PRODUCT_ID = p.PRODUCT_ID
WHERE
    t.SALES_VALUE > 0
    AND p.DEPARTMENT = 'GROCERY'
GROUP BY p.COMMODITY_DESC;

SELECT
    ROUND(SUM(total_sales), 2) AS total_grocery_sales
FROM vw_grocery_category_performance;

#Buat view Top 10 Grocery Categories
CREATE OR REPLACE VIEW vw_top10_grocery_categories AS
SELECT
    COMMODITY_DESC,
    total_sales,
    ROUND(
        total_sales * 100.0 / 4093814.14,
        2
    ) AS sales_contribution_pct,
    total_quantity,
    total_baskets,
    total_households
FROM vw_grocery_category_performance
ORDER BY total_sales DESC
LIMIT 10;

SELECT *
FROM vw_top10_grocery_categories;


#View Top 10 Products
CREATE OR REPLACE VIEW vw_top10_products AS
SELECT
    p.PRODUCT_ID,
    p.BRAND,
    p.DEPARTMENT,
    p.COMMODITY_DESC,
    p.SUB_COMMODITY_DESC,
    v.total_sales,
    v.total_quantity,
    v.total_baskets,
    v.total_households
FROM vw_product_performance v
LEFT JOIN product p
    ON v.PRODUCT_ID = p.PRODUCT_ID
ORDER BY v.total_sales DESC
LIMIT 10;

SELECT *
FROM vw_top10_products;

# View Top 10 Grocery Products
CREATE OR REPLACE VIEW vw_top10_grocery_products AS
SELECT
    p.PRODUCT_ID,
    p.BRAND,
    p.COMMODITY_DESC,
    p.SUB_COMMODITY_DESC,
    p.CURR_SIZE_OF_PRODUCT,
    ROUND(SUM(t.SALES_VALUE), 2) AS total_sales,
    SUM(t.QUANTITY) AS total_quantity,
    COUNT(DISTINCT t.BASKET_ID) AS total_baskets,
    COUNT(DISTINCT t.household_key) AS total_households
FROM transaction_data t
JOIN product p
    ON t.PRODUCT_ID = p.PRODUCT_ID
WHERE
    t.SALES_VALUE > 0
    AND p.DEPARTMENT = 'GROCERY'
GROUP BY
    p.PRODUCT_ID,
    p.BRAND,
    p.COMMODITY_DESC,
    p.SUB_COMMODITY_DESC,
    p.CURR_SIZE_OF_PRODUCT
ORDER BY total_sales DESC
LIMIT 10;

SELECT *
FROM vw_top10_grocery_products;

#Sales by Store
CREATE OR REPLACE VIEW vw_store_performance AS
SELECT
    STORE_ID,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    SUM(QUANTITY) AS total_quantity,
    COUNT(DISTINCT BASKET_ID) AS total_baskets,
    COUNT(DISTINCT household_key) AS total_households
FROM transaction_data
WHERE SALES_VALUE > 0
GROUP BY STORE_ID;

SELECT *
FROM vw_store_performance
ORDER BY total_sales DESC
LIMIT 10;

# View kontribusi sales setiap store
CREATE OR REPLACE VIEW vw_store_sales_contribution AS
SELECT
    STORE_ID,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    ROUND(
        SUM(SALES_VALUE) * 100.0 /
        (SELECT SUM(SALES_VALUE)
         FROM transaction_data
         WHERE SALES_VALUE > 0),
        2
    ) AS sales_contribution_pct
FROM transaction_data
WHERE SALES_VALUE > 0
GROUP BY STORE_ID;

SELECT *
FROM vw_store_sales_contribution
ORDER BY total_sales DESC
LIMIT 10;

#Penjualan per jam
SELECT
    FLOOR(TRANS_TIME / 100) AS transaction_hour,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    COUNT(DISTINCT BASKET_ID) AS total_baskets
FROM transaction_data
WHERE SALES_VALUE > 0
GROUP BY FLOOR(TRANS_TIME / 100)
ORDER BY transaction_hour;

#View sales by hour
CREATE OR REPLACE VIEW vw_sales_by_hour AS
SELECT
    FLOOR(TRANS_TIME / 100) AS transaction_hour,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    COUNT(DISTINCT BASKET_ID) AS total_baskets
FROM transaction_data
WHERE SALES_VALUE > 0
GROUP BY FLOOR(TRANS_TIME / 100);

SELECT *
FROM vw_sales_by_hour
ORDER BY transaction_hour;

# View vw_sales_by_day
CREATE OR REPLACE VIEW vw_sales_by_day AS
SELECT
    DAY,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    SUM(QUANTITY) AS total_quantity,
    COUNT(DISTINCT BASKET_ID) AS total_baskets,
    COUNT(DISTINCT household_key) AS total_households
FROM transaction_data
WHERE SALES_VALUE > 0
GROUP BY DAY;

SELECT *
FROM vw_sales_by_day
ORDER BY DAY;

SELECT COUNT(*) AS total_days
FROM vw_sales_by_day;

#Top 10 days by sales
SELECT *
FROM vw_sales_by_day
ORDER BY total_sales DESC
LIMIT 10;

#Bottom 10 days by sales
SELECT *
FROM vw_sales_by_day
ORDER BY total_sales ASC
LIMIT 10;

#Periksa aktivitas transaksi pada hari ekstrem
SELECT
    DAY,
    COUNT(*) AS total_records,
    COUNT(DISTINCT BASKET_ID) AS total_baskets,
    COUNT(DISTINCT household_key) AS total_households,
    ROUND(SUM(SALES_VALUE), 2) AS total_sales
FROM transaction_data
WHERE DAY IN (643, 278, 641, 692)
  AND SALES_VALUE > 0
GROUP BY DAY
ORDER BY DAY;

SELECT
    ROUND(SUM(total_sales), 2) AS daily_sales_total
FROM vw_sales_by_day;

#View KPI
CREATE OR REPLACE VIEW vw_sales_overview AS
SELECT
    ROUND(SUM(SALES_VALUE), 2) AS total_sales,
    SUM(QUANTITY) AS total_quantity,
    COUNT(DISTINCT BASKET_ID) AS total_baskets,
    COUNT(DISTINCT household_key) AS total_households
FROM transaction_data
WHERE SALES_VALUE > 0;

SELECT *
FROM vw_sales_overview;


