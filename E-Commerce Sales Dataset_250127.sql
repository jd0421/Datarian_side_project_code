-- data : https://www.kaggle.com/datasets/thedevastator/unlock-profits-with-e-commerce-sales-data/data

-- 000. preprocessing

-- SELECT *
-- FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report` 
-- LIMIT 100


-- 001. 각 컬럼명 확인 
-- 총 24개 컬럼 확인
-- index
-- Order ID
-- Date
-- Status
-- Fulfilment
-- Sales Channel
-- ship-service-level
-- Style
-- SKU
-- Category
-- Size
-- ASIN
-- Courier Status
-- Qty
-- currency
-- Amount
-- ship-city
-- ship-state
-- ship-postal-code
-- ship-country
-- promotion-ids
-- B2B
-- fulfilled-by
-- Unnamed: 22

SELECT 
    column_name,
FROM `datarian-sql-447611.Project_250127.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'Amazon_Sale_Report'

-- 000. 컬럼별 결측값 확인

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN "index" IS NULL THEN 1 ELSE 0 END) AS index_nulls,
    SUM(CASE WHEN `Order ID` IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN `Date` IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN `Status` IS NULL THEN 1 ELSE 0 END) AS status_nulls,
    SUM(CASE WHEN `Fulfilment` IS NULL THEN 1 ELSE 0 END) AS fulfilment_nulls,
    SUM(CASE WHEN "Sales Channel" IS NULL THEN 1 ELSE 0 END) AS sales_channel_nulls,
    SUM(CASE WHEN `ship-service-level` IS NULL THEN 1 ELSE 0 END) AS ship_service_level_nulls,
    SUM(CASE WHEN `Style` IS NULL THEN 1 ELSE 0 END) AS style_nulls,
    SUM(CASE WHEN `SKU` IS NULL THEN 1 ELSE 0 END) AS sku_nulls,
    SUM(CASE WHEN `Category` IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN `Size` IS NULL THEN 1 ELSE 0 END) AS size_nulls,
    SUM(CASE WHEN `ASIN` IS NULL THEN 1 ELSE 0 END) AS asin_nulls,
    SUM(CASE WHEN `Courier Status` IS NULL THEN 1 ELSE 0 END) AS courier_status_nulls,
    SUM(CASE WHEN `Qty` IS NULL THEN 1 ELSE 0 END) AS qty_nulls,
    SUM(CASE WHEN `currency` IS NULL THEN 1 ELSE 0 END) AS currency_nulls,
    SUM(CASE WHEN `Amount` IS NULL THEN 1 ELSE 0 END) AS amount_nulls,
    SUM(CASE WHEN `ship-city` IS NULL THEN 1 ELSE 0 END) AS ship_city_nulls,
    SUM(CASE WHEN `ship-state` IS NULL THEN 1 ELSE 0 END) AS ship_state_nulls,
    SUM(CASE WHEN `ship-postal-code` IS NULL THEN 1 ELSE 0 END) AS ship_postal_code_nulls,
    SUM(CASE WHEN `ship-country` IS NULL THEN 1 ELSE 0 END) AS ship_country_nulls,
    SUM(CASE WHEN `promotion-ids` IS NULL THEN 1 ELSE 0 END) AS promotion_ids_nulls,
    SUM(CASE WHEN `B2B` IS NULL THEN 1 ELSE 0 END) AS b2b_nulls,
    SUM(CASE WHEN `fulfilled-by` IS NULL THEN 1 ELSE 0 END) AS fulfilled_by_nulls,
    SUM(CASE WHEN `Unnamed: 22` IS NULL THEN 1 ELSE 0 END) AS unnamed_22_nulls
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`;

-- 000. 컬럼별 unique value 수 확인
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `index`) AS index_unique,
    COUNT(DISTINCT `Order ID`) AS order_id_unique,
    COUNT(DISTINCT `Date`) AS date_unique,
    COUNT(DISTINCT `Status`) AS status_unique,
    COUNT(DISTINCT `Fulfilment`) AS fulfilment_unique,
    COUNT(DISTINCT "Sales Channel") AS sales_channel_unique,
    COUNT(DISTINCT `ship-service-level`) AS ship_service_level_unique,
    COUNT(DISTINCT `Style`) AS style_unique,
    COUNT(DISTINCT `SKU`) AS sku_unique,
    COUNT(DISTINCT `Category`) AS category_unique,
    COUNT(DISTINCT `Size`) AS size_unique,
    COUNT(DISTINCT `ASIN`) AS asin_unique,
    COUNT(DISTINCT `Courier Status`) AS courier_status_unique,
    COUNT(DISTINCT `Qty`) AS qty_unique,
    COUNT(DISTINCT `currency`) AS currency_unique,
    COUNT(DISTINCT `Amount`) AS amount_unique,
    COUNT(DISTINCT `ship-city`) AS ship_city_unique,
    COUNT(DISTINCT `ship-state`) AS ship_state_unique,
    COUNT(DISTINCT `ship-postal-code`) AS ship_postal_code_unique,
    COUNT(DISTINCT `ship-country`) AS ship_country_unique,
    COUNT(DISTINCT `promotion-ids`) AS promotion_ids_unique,
    COUNT(DISTINCT `B2B`) AS b2b_unique,
    COUNT(DISTINCT `fulfilled-by`) AS fulfilled_by_unique,
    COUNT(DISTINCT `Unnamed: 22`) AS unnamed_22_unique
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`;

-- 000. 컬럼별 데이터 타입 조회
SELECT 
    column_name, 
    data_type
FROM `datarian-sql-447611.Project_250127.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'Amazon_Sale_Report';

-- 000. 불필요한 컬럼 제외 

-- index 미사용
-- order_id 미사용
-- date 유지

-- Status
-- 유지, Shipped, Shipped - Delivered to Buyer 만 sort
SELECT
  `Status`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- Fullfillment
-- 제외, Amazon 69.55, Merchant 30.45
SELECT
  `Fulfilment`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- Sales Channel -- unique 값 1개, 결측값 0 으로 제외
SELECT
  "Sales Channel"
  , COUNT(*)
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1

-- ship-service-level
-- 유지, Expedited 88615, Standard 40360 
SELECT
  `ship-service-level`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- Style : 유지
SELECT
  `Style`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- SKU : 불필요, 제외 

-- Category
-- 유지, top 4 category : Set, Kurta, Western Dress, Top 
SELECT
  `Category`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- Size
-- 유지 
SELECT
  `Size`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- ASIN 제외, 주제와 무관 

-- Courier Status
-- 포함, Shipped 정보 대상으로만 진행, 109487 
SELECT
  `Courier Status`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- Qty
-- 불필요, 제외 
SELECT
  `Qty`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- currency
-- 유지, INR 값만 진행, 121180
SELECT
  `currency`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- Amount
-- 유지, 판매 금액, NULL 값은 제외 

-- ship-city
-- 유지, 판매 지역 상세 
SELECT
  `ship-city`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- ship-state
-- 유지, 판매 지역 상세 
SELECT
  `ship-state`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- ship-postal-code
-- ship-country
-- 불필요 제외


-- promotion-ids
-- 불필요, 제외
SELECT
  `promotion-ids`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- B2B
-- 불필요, 제외 
SELECT
  `B2B`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- fulfilled-by -- 불필요, 제외
-- Unnamed: 22 -- 불필요, 제외

SELECT
  `fulfilled-by`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

SELECT
  `Unnamed: 22`,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

------------------------------------------------------------------------------------

-- 000. CONDITION FILTERING

WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    count(*)
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
 
SELECT 
  *
FROM 
  FILTERED_Amazon_Sale_Report
LIMIT 10

------------------------------------------------------------------------------------

-- 1) 기본 매출 분석
-- [Category, Amount] → 제품 카테고리별 매출 기여도 분석
-- [Style, Amount] → 특정 스타일별 수익성 비교
-- [Category, Qty, Amount] → 카테고리별 판매량과 총 매출 비교
-- [Style, Qty, Amount] → 스타일별 판매량과 총 매출 비교
-- 2) 수익성 최적화를 위한 제품 특성 분석
-- [Category, Size, Amount] → 카테고리와 사이즈 조합별 수익성 분석
-- [Style, Size, Amount] → 스타일과 사이즈 조합별 수익성 분석
-- [Category, Size, Qty, Amount] → 특정 카테고리에서 가장 많이 팔리는 사이즈 조합 분석
-- [Style, Size, Qty, Amount] → 특정 스타일에서 가장 많이 팔리는 사이즈 조합 분석
-- 3) 지역별 수익성 분석
-- [ship-city, Category, Amount] → 도시별 인기 카테고리 분석
-- [ship-state, Category, Amount] → 주/지역별 인기 카테고리 분석
-- [ship-city, Style, Amount] → 도시별 인기 스타일 분석
-- [ship-state, Style, Amount] → 주/지역별 인기 스타일 분석
-- 4) 배송과 매출 간 관계 분석
-- [ship-service-level, Amount] → 배송 서비스 수준과 매출 간의 관계
-- [ship-service-level, Qty, Amount] → 빠른 배송이 판매량에 미치는 영향
-- [Courier Status, Amount] → 배송 상태가 매출에 미치는 영향
-- [ship-service-level, Courier Status, Amount] → 배송 속도와 성공적인 배송이 매출에 미치는 영향
-- 5) 통화 및 가격 전략 분석
-- [currency, Amount] → 여러 통화로 결제된 제품의 매출 차이 분석
-- [Category, currency, Amount] → 통화에 따른 카테고리별 매출 차이
-- [ship-state, currency, Amount] → 주/지역별 통화 사용 패턴과 매출 관계
-- [ship-service-level, currency, Amount] → 특정 배송 서비스와 통화 간의 관계 분석
------------------------------------------------------------------------------------

-- 1) 기본 매출 분석

-- [Category, Amount] → 제품 카테고리별 매출 기여도 분석

WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
 
, Category_Sales AS (
  SELECT 
    Category, 
    SUM(Amount) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY Category
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM Category_Sales
)

SELECT 
  cs.Category, 
  cs.total_revenue, 
  cs.total_orders,
  (cs.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM Category_Sales cs, Total_Sales ts
ORDER BY cs.total_revenue DESC;



-- [Style, Amount] → 특정 스타일별 수익성 비교
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)

, Style_Sales AS (
  SELECT 
    Style, 
    SUM(Amount) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY Style
), Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM Style_Sales
)
SELECT 
  ss.Style, 
  ss.total_revenue, 
  ss.total_orders,
  (ss.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM Style_Sales ss, Total_Sales ts
ORDER BY ss.total_revenue DESC;

-- [Category, Qty, Amount] → 카테고리별 판매량과 총 매출 비교
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, Category_Sales AS (
  SELECT 
    Category, 
    SUM(Qty) AS total_quantity_sold,
    SUM(Amount) AS total_revenue,
    AVG(Amount / Qty) AS avg_price_per_unit
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY Category
), Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM Category_Sales
)
SELECT 
  cs.Category, 
  cs.total_quantity_sold, 
  cs.total_revenue,
  cs.avg_price_per_unit,
  (cs.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM Category_Sales cs, Total_Sales ts
ORDER BY cs.total_revenue DESC;


-- [Style, Qty, Amount] → 스타일별 판매량과 총 매출 비교

WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, Style_Sales AS (
  SELECT 
    Style, 
    SUM(Qty) AS total_quantity_sold,
    SUM(Amount) AS total_revenue,
    AVG(Amount / Qty) AS avg_price_per_unit
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY Style
), Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM Style_Sales
)
SELECT 
  ss.Style, 
  ss.total_quantity_sold, 
  ss.total_revenue,
  ss.avg_price_per_unit,
  (ss.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM Style_Sales ss, Total_Sales ts
ORDER BY ss.total_revenue DESC;


-- 2) 수익성 최적화를 위한 제품 특성 분석
-- [Category, Size, Amount] → 카테고리와 사이즈 조합별 수익성 분석
-- [Style, Size, Amount] → 스타일과 사이즈 조합별 수익성 분석
-- [Category, Size, Qty, Amount] → 특정 카테고리에서 가장 많이 팔리는 사이즈 조합 분석
-- [Style, Size, Qty, Amount] → 특정 스타일에서 가장 많이 팔리는 사이즈 조합 분석

-- [Category, Size, Amount] → 카테고리와 사이즈 조합별 수익성 분석

WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, Category_Size_Sales AS (
  SELECT 
    Category, 
    Size, 
    SUM(Amount) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY Category, Size
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM Category_Size_Sales
)

SELECT 
  cs.Category, 
  cs.Size,
  cs.total_revenue, 
  cs.total_orders,
  (cs.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM Category_Size_Sales cs, Total_Sales ts
ORDER BY cs.total_revenue DESC;

-- [Style, Size, Amount] → 스타일과 사이즈 조합별 수익성 분석

WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, Style_Size_Sales AS (
  SELECT 
    Style, 
    Size, 
    SUM(Amount) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY Style, Size
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM Style_Size_Sales
)

SELECT 
  ss.Style, 
  ss.Size,
  ss.total_revenue, 
  ss.total_orders,
  (ss.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM Style_Size_Sales ss, Total_Sales ts
ORDER BY ss.total_revenue DESC;

-- [Category, Size, Qty, Amount] → 특정 카테고리에서 가장 많이 팔리는 사이즈 조합 분석
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, Category_Size_Qty AS (
  SELECT 
    Category, 
    Size, 
    SUM(Qty) AS total_quantity_sold,
    SUM(Amount) AS total_revenue,
    AVG(Amount / Qty) AS avg_price_per_unit
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY Category, Size
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM Category_Size_Qty
)

SELECT 
  cq.Category, 
  cq.Size,
  cq.total_quantity_sold, 
  cq.total_revenue,
  cq.avg_price_per_unit,
  (cq.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM Category_Size_Qty cq, Total_Sales ts
ORDER BY cq.total_revenue DESC;

-- [Style, Size, Qty, Amount] → 특정 스타일에서 가장 많이 팔리는 사이즈 조합 분석
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, Style_Size_Qty AS (
  SELECT 
    Style, 
    Size, 
    SUM(Qty) AS total_quantity_sold,
    SUM(Amount) AS total_revenue,
    AVG(Amount / Qty) AS avg_price_per_unit
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY Style, Size
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM Style_Size_Qty
)

SELECT 
  sq.Style, 
  sq.Size,
  sq.total_quantity_sold, 
  sq.total_revenue,
  sq.avg_price_per_unit,
  (sq.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM Style_Size_Qty sq, Total_Sales ts
ORDER BY sq.total_revenue DESC;

-- 3) 지역별 수익성 분석
-- [ship-city, Category, Amount] → 도시별 인기 카테고리 분석
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, City_Category_Sales AS (
  SELECT 
    `ship-city`, 
    `Category`, 
    SUM(`Amount`) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY `ship-city`, `Category`
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM City_Category_Sales
)

SELECT 
  cc.`ship-city`, 
  cc.`Category`,
  cc.total_revenue, 
  cc.total_orders,
  (cc.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM City_Category_Sales cc, Total_Sales ts
ORDER BY cc.total_revenue DESC;

-- [ship-state, Category, Amount] → 주/지역별 인기 카테고리 분석
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, State_Category_Sales AS (
  SELECT 
    `ship-state`, 
    `Category`, 
    SUM(`Amount`) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY `ship-state`, `Category`
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM State_Category_Sales
)

SELECT 
  sc.`ship-state`, 
  sc.`Category`,
  sc.total_revenue, 
  sc.total_orders,
  (sc.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM State_Category_Sales sc, Total_Sales ts
ORDER BY sc.total_revenue DESC;

-- [ship-city, Style, Amount] → 도시별 인기 스타일 분석 - 이건 top 10 이렇게 봅아야 겠다
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, City_Style_Sales AS (
  SELECT 
    `ship-city`, 
    `Style`, 
    SUM(`Amount`) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY `ship-city`, `Style`
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM City_Style_Sales
)

SELECT 
  cs.`ship-city`, 
  cs.`Style`,
  cs.total_revenue, 
  cs.total_orders,
  (cs.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM City_Style_Sales cs, Total_Sales ts
ORDER BY cs.total_revenue DESC;


-- [ship-state, Style, Amount] → 주/지역별 인기 스타일 분석 - 이건 top 10 이렇게 뽑아야 겠다
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, State_Style_Sales AS (
  SELECT 
    `ship-state`, 
    `Style`, 
    SUM(`Amount`) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY `ship-state`, `Style`
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM State_Style_Sales
)

SELECT 
  ss.`ship-state`, 
  ss.`Style`,
  ss.total_revenue, 
  ss.total_orders,
  (ss.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM State_Style_Sales ss, Total_Sales ts
ORDER BY ss.total_revenue DESC;

-- 4) 배송과 매출 간 관계 분석
-- [ship-service-level, Amount] → 배송 서비스 수준과 매출 간의 관계
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, ShipService_Sales AS (
  SELECT 
    `ship-service-level`, 
    SUM(`Amount`) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY `ship-service-level`
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM ShipService_Sales
)

SELECT 
  ss.`ship-service-level`, 
  ss.total_revenue, 
  ss.total_orders,
  (ss.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM ShipService_Sales ss, Total_Sales ts
ORDER BY ss.total_revenue DESC;

-- [ship-service-level, Qty, Amount] → 빠른 배송이 판매량에 미치는 영향
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)

, ShipService_Qty_Sales AS (
  SELECT 
    `ship-service-level`, 
    SUM(`Qty`) AS total_quantity_sold,
    SUM(`Amount`) AS total_revenue,
    AVG(`Amount` / `Qty`) AS avg_price_per_unit
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY `ship-service-level`
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM ShipService_Qty_Sales
)

SELECT 
  sqs.`ship-service-level`, 
  sqs.total_quantity_sold, 
  sqs.total_revenue,
  sqs.avg_price_per_unit,
  (sqs.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM ShipService_Qty_Sales sqs, Total_Sales ts
ORDER BY sqs.total_revenue DESC;

-- [Courier Status, Amount] → 배송 상태가 매출에 미치는 영향
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, CourierStatus_Sales AS (
  SELECT 
    `Courier Status`, 
    SUM(`Amount`) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY `Courier Status`
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM CourierStatus_Sales
)

SELECT 
  cs.`Courier Status`, 
  cs.total_revenue, 
  cs.total_orders,
  (cs.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM CourierStatus_Sales cs, Total_Sales ts
ORDER BY cs.total_revenue DESC;

-- [ship-service-level, Courier Status, Amount] → 배송 속도와 성공적인 배송이 매출에 미치는 영향
WITH FILTERED_Amazon_Sale_Report AS (
  SELECT
    *
  FROM `datarian-sql-447611.Project_250127.Amazon_Sale_Report`
  WHERE
    `Status` IN ("Shipped", "Shipped - Delivered to Buyer") -- 106573
    AND `ship-service-level` IN ("Expedited", "Standard") -- 106573
    AND `Category` IN ("Set", "kurta", "Western Dress", "Top") -- 104287
    AND `Courier Status` IN ("Shipped") -- 104077
    AND `currency` IN ("INR") -- 104077
    AND `Amount` IS NOT NULL -- 104077
)
, ShipService_CourierStatus_Sales AS (
  SELECT 
    `ship-service-level`, 
    `Courier Status`, 
    SUM(`Amount`) AS total_revenue,
    COUNT(*) AS total_orders
  FROM FILTERED_Amazon_Sale_Report
  GROUP BY `ship-service-level`, `Courier Status`
)

, Total_Sales AS (
  SELECT SUM(total_revenue) AS grand_total FROM ShipService_CourierStatus_Sales
)

SELECT 
  scs.`ship-service-level`, 
  scs.`Courier Status`, 
  scs.total_revenue, 
  scs.total_orders,
  (scs.total_revenue / ts.grand_total) * 100 AS revenue_percentage
FROM ShipService_CourierStatus_Sales scs, Total_Sales ts
ORDER BY scs.total_revenue DESC;






