-- select count(*)
-- from `test_250119.Action_logs_dataset` as action
-- join `test_250119.Aha_Moments_Dataset` as aha on action.User_ID = aha.User_ID
-- -- join `test_250119.User_Profile_Dataset` as user on action.User_ID = user.User_ID
-- limit 10
-- ;


-- Action_Logs_Dataset.csv
-- 1. 행동 유형(Action_Type)별 사용자 비율 분석
SELECT 
  FORMAT_TIMESTAMP('%Y-%m', Action_Timestamp) AS YearMonth,
  Action_Type,
  COUNT(DISTINCT User_ID) AS User_Count,
  COUNT(*) AS Action_Count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Action_Percentage
FROM `test_250119.Action_logs_dataset`
GROUP BY 
  FORMAT_TIMESTAMP('%Y-%m', Action_Timestamp)
  , Action_Type
ORDER BY 
  1, 2;

-- 2. 행동별 평균 소요 시간 계산 (Login → Purchase)
-- 특정 행동(Login → Purchase)까지 평균 소요 시간 계산
WITH Login_Timestamps AS (
  SELECT 
    User_ID,
    MIN(Action_Timestamp) AS Login_Time
  FROM `test_250119.Action_logs_dataset`
  WHERE 
    Action_Type = 'Login'
  GROUP BY 
    User_ID
),
Purchase_Timestamps AS (
  SELECT 
    User_ID,
    MIN(Action_Timestamp) AS Purchase_Time
  FROM `test_250119.Action_logs_dataset`
  WHERE 
    Action_Type = 'Purchase'
  GROUP BY 
    User_ID
)
SELECT 
  l.User_ID,
  TIMESTAMP_DIFF(p.Purchase_Time, l.Login_Time, SECOND) AS Time_To_Purchase_second
  , TIMESTAMP_DIFF(p.Purchase_Time, l.Login_Time, MINUTE) AS Time_To_Purchase_minute
  , TIMESTAMP_DIFF(p.Purchase_Time, l.Login_Time, HOUR) AS Time_To_Purchase_hour
  , TIMESTAMP_DIFF(p.Purchase_Time, l.Login_Time, DAY) AS Time_To_Purchase_day

FROM 
  Login_Timestamps l
JOIN 
  Purchase_Timestamps p
ON 
  l.User_ID = p.User_ID
WHERE 
  TIMESTAMP_DIFF(p.Purchase_Time, l.Login_Time, SECOND) > 0;

-- 3. 특정 행동 이탈률 분석 (Add_To_Cart → Purchase) 
-- Add_To_Cart에서 Purchase로 이어지지 않은 사용자 분석
WITH AddToCart AS (
  SELECT 
    User_ID,
    COUNT(*) AS Add_To_Cart_Count
  FROM 
    `test_250119.Action_logs_dataset`
  WHERE 
    Action_Type = 'Add_To_Cart'
  GROUP BY 
    User_ID
),
Purchases AS (
  SELECT 
    User_ID,
    COUNT(*) AS Purchase_Count
  FROM 
    `test_250119.Action_logs_dataset`
  WHERE 
    Action_Type = 'Purchase'
  GROUP BY 
    User_ID
)
SELECT 
  a.User_ID,
  a.Add_To_Cart_Count,
  IFNULL(p.Purchase_Count, 0) AS Purchase_Count,
  CASE 
    WHEN p.Purchase_Count IS NULL THEN 'Churned'
    ELSE 'Converted'
  END AS Status
FROM 
  AddToCart a
LEFT JOIN 
  Purchases p
ON 
  a.User_ID = p.User_ID;

-- 4. 전체 사용자 행동 흐름 분석
-- 사용자별 전체 행동 흐름 분석
SELECT 
  User_ID,
  ARRAY_AGG(Action_Type ORDER BY Action_Timestamp) AS Action_Flow
FROM 
  `test_250119.Action_logs_dataset`
GROUP BY 
  User_ID;


-- 5. 행동 시간대 분석
-- 사용자 행동이 주로 발생하는 시간대 분석
SELECT 
  Action_Type,
  EXTRACT(HOUR FROM Action_Timestamp) AS Hour,
  COUNT(*) AS Action_Count
FROM 
  `test_250119.Action_logs_dataset`
GROUP BY 
  Action_Type, Hour
ORDER BY 
  Action_Type, Hour;


---Aha_Moments_Dataset.csv

-- 1. Aha Moment 발생 패턴 분석
-- Aha_Action_Type별 Aha Moment 발생 빈도와 리텐션율 분석
SELECT 
  Aha_Action_Type,
  COUNT(*) AS Aha_Moment_Count,
  ROUND(AVG(Retention_After_Aha_7d) * 100, 2) AS Avg_Retention_7d,
  ROUND(AVG(Retention_After_Aha_30d) * 100, 2) AS Avg_Retention_30d
FROM 
  `test_250119.Aha_Moments_Dataset`
GROUP BY 
  Aha_Action_Type
ORDER BY 
  Aha_Moment_Count DESC;

-- *. Aha Moment와 리텐션 비교 

-- Aha Moment를 경험한 사용자와 경험하지 않은 사용자의 리텐션 비교
-- WITH Aha_Moment_Users AS (
--   SELECT DISTINCT User_ID
--   FROM `test_250119.Aha_Moments_Dataset`
-- ),
-- Retention_Comparison AS (
--   SELECT 
--     a.User_ID,
--     1 AS Experienced_Aha_Moment,
--     a.Retention_After_Aha_7d,
--     a.Retention_After_Aha_30d
--   FROM 
--     `test_250119.Aha_Moments_Dataset` a
--   UNION ALL
--   SELECT 
--     u.User_ID,
--     0 AS Experienced_Aha_Moment,
--     NULL AS Retention_After_Aha_7d,
--     NULL AS Retention_After_Aha_30d
--   FROM 
--     (SELECT DISTINCT User_ID FROM `test_250119.User_Profile_Dataset`) u
--   WHERE 
--     u.User_ID NOT IN (SELECT User_ID FROM Aha_Moment_Users)
-- )
-- SELECT 
--   Experienced_Aha_Moment,
--   COUNT(distinct User_ID) AS User_Count,
--   ROUND(AVG(Retention_After_Aha_7d) * 100, 2) AS Avg_Retention_7d,
--   ROUND(AVG(Retention_After_Aha_30d) * 100, 2) AS Avg_Retention_30d
-- FROM 
--   Retention_Comparison
-- GROUP BY 
--   Experienced_Aha_Moment
-- ORDER BY 
--   Experienced_Aha_Moment DESC;


-- 2. 시간대별 Aha Moment 분석
-- Aha Moment가 발생한 시간대 분석
SELECT 
  EXTRACT(HOUR FROM TIMESTAMP(Aha_Action_Timestamp)) AS Hour
  , sum(case when Aha_Action_Type = 'Click_Product' then 1 else 0 end) as Click_Product
  , sum(case when Aha_Action_Type = 'Add_To_Cart' then 1 else 0 end) as Add_To_Cart
  , sum(case when Aha_Action_Type = 'First_Purchase' then 1 else 0 end) as First_Purchase
FROM 
  `test_250119.Aha_Moments_Dataset`
group by
  1
ORDER BY 
  Hour;


-- 3. 사용자 세그먼트별 Aha Moment 효과 분석
-- Aha Moment count 수와 평균 리텐션 간 상관관계
SELECT 
  User_ID,
  COUNT(*) AS Aha_Moment_Count,
  ROUND(AVG(Retention_After_Aha_7d) * 100, 2) AS Avg_Retention_7d,
  ROUND(AVG(Retention_After_Aha_30d) * 100, 2) AS Avg_Retention_30d
FROM 
  `test_250119.Aha_Moments_Dataset`
GROUP BY 
  User_ID
ORDER BY 
  Aha_Moment_Count DESC
;
  

with step1 as (SELECT 
  User_ID,
  COUNT(*) AS Aha_Moment_Count,
  ROUND(AVG(Retention_After_Aha_7d) * 100, 2) AS Avg_Retention_7d,
  ROUND(AVG(Retention_After_Aha_30d) * 100, 2) AS Avg_Retention_30d
FROM 
  `test_250119.Aha_Moments_Dataset`
GROUP BY 
  User_ID
ORDER BY 
  Aha_Moment_Count DESC)

SELECT 
  Aha_Moment_Count
  , count(Aha_Moment_Count) AS User_Count
  , ROUND(AVG(Avg_Retention_7d), 2) AS Avg_Retention_7d
  , ROUND(AVG(Avg_Retention_30d), 2) AS Avg_Retention_30d

FROM
  step1

GROUP BY
  1
ORDER BY
  1 DESC
  
--- User_Profile_Dataset.csv

-- 1. 사용자 세그먼트 분석
-- 목적: 사용자 그룹을 정의하여 각 그룹의 행동 패턴과 리텐션 차이를 파악.
-- 분석 방법:
-- 가입 시기별 사용자 그룹화 (Cohort Analysis).
-- 사용자 활동 수준(Total_Activity_Count)에 따라 고/중/저 활동 사용자로 세그먼트화.
-- 활용: 사용자별 맞춤형 캠페인 설계.

-- 사용자 활동 수준에 따른 세그먼트화
-- 결과:
-- 활동 수준별 사용자 비율과 평균 리텐션율.

SELECT 
  CASE 
    WHEN Total_Activity_Count >= 30 THEN 'High Activity'
    WHEN Total_Activity_Count >= 10 THEN 'Medium Activity'
    ELSE 'Low Activity'
  END AS Activity_Segment,
  COUNT(User_ID) AS User_Count,
  ROUND(AVG(Retention_Status_7d) * 100, 2) AS Avg_Retention_7d,
  ROUND(AVG(Retention_Status_30d) * 100, 2) AS Avg_Retention_30d
FROM 
  `test_250119.User_Profile_Dataset`
GROUP BY 
  Activity_Segment
ORDER BY 
  User_Count DESC;

-- 2. 이탈률(Churn Rate) 분석
-- 7일 및 30일 이탈률 계산
-- 목적: 사용자가 서비스에서 이탈하는 주요 원인과 이탈 비율을 분석.
-- 분석 방법:
-- Retention_Status_7d와 Retention_Status_30d 데이터를 사용해 이탈률 계산.
-- 이탈 사용자와 유지 사용자 간의 활동 수준 비교.
-- 활용: 이탈 가능성이 높은 사용자 조기 탐지 및 예방 캠페인 실행.

SELECT 
  COUNT(User_ID) AS Total_Users,
  COUNTIF(Retention_Status_7d = 0) AS Churned_Users_7d,
  COUNTIF(Retention_Status_30d = 0) AS Churned_Users_30d,
  ROUND(COUNTIF(Retention_Status_7d = 0) * 100.0 / COUNT(User_ID), 2) AS Churn_Rate_7d,
  ROUND(COUNTIF(Retention_Status_30d = 0) * 100.0 / COUNT(User_ID), 2) AS Churn_Rate_30d
FROM 
  `test_250119.User_Profile_Dataset`;


-- 3. 활성 사용자 행동 분석 / DAU, WAU, MAU 계산
-- 목적: 서비스를 가장 자주 사용하는 활성 사용자의 행동 패턴 이해.
-- 분석 방법:
-- DAU, WAU, MAU 계산.
-- 활성 사용자 비율 = DAU / MAU.
-- 활용: 지속적으로 방문하도록 리텐션 강화 전략 설계.

-- DAU, WAU, MAU 계산

-- DAU
SELECT
  SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-01-31') THEN 1 ELSE 0 END) mth1
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-02-29') THEN 1 ELSE 0 END) mth2
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-03-31') THEN 1 ELSE 0 END) mth3
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-04-30') THEN 1 ELSE 0 END) mth4
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-05-31') THEN 1 ELSE 0 END) mth5
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-06-30') THEN 1 ELSE 0 END) mth6
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-07-31') THEN 1 ELSE 0 END) mth7
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-08-31') THEN 1 ELSE 0 END) mth8
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-09-30') THEN 1 ELSE 0 END) mth9
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-10-31') THEN 1 ELSE 0 END) mth10
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-11-30') THEN 1 ELSE 0 END) mth11
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-12-31') THEN 1 ELSE 0 END) mth12
--  , SUM(CASE WHEN First_Purchase_Date BETWEEN '2024-01-01' AND '2024-12-31' THEN First_Purchase_Date ELSE 0 END) CHK
FROM 
  `test_250119.User_Profile_Dataset`

UNION ALL
-- WAU
SELECT
  SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-01-31') THEN Retention_Status_7d ELSE 0 END) mth1
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-02-29') THEN Retention_Status_7d ELSE 0 END) mth2
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-03-31') THEN Retention_Status_7d ELSE 0 END) mth3
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-04-30') THEN Retention_Status_7d ELSE 0 END) mth4
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-05-31') THEN Retention_Status_7d ELSE 0 END) mth5
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-06-30') THEN Retention_Status_7d ELSE 0 END) mth6
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-07-31') THEN Retention_Status_7d ELSE 0 END) mth7
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-08-31') THEN Retention_Status_7d ELSE 0 END) mth8
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-09-30') THEN Retention_Status_7d ELSE 0 END) mth9
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-10-31') THEN Retention_Status_7d ELSE 0 END) mth10
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-11-30') THEN Retention_Status_7d ELSE 0 END) mth11
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-12-31') THEN Retention_Status_7d ELSE 0 END) mth12
--  , SUM(CASE WHEN First_Purchase_Date BETWEEN '2024-01-01' AND '2024-12-31' THEN Retention_Status_7d ELSE 0 END) CHK
FROM 
  `test_250119.User_Profile_Dataset`

UNION ALL 
--- MAU
SELECT
  SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-01-31') THEN Retention_Status_30d ELSE 0 END) mth1
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-02-29') THEN Retention_Status_30d ELSE 0 END) mth2
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-03-31') THEN Retention_Status_30d ELSE 0 END) mth3
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-04-30') THEN Retention_Status_30d ELSE 0 END) mth4
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-05-31') THEN Retention_Status_30d ELSE 0 END) mth5
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-06-30') THEN Retention_Status_30d ELSE 0 END) mth6
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-07-31') THEN Retention_Status_30d ELSE 0 END) mth7
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-08-31') THEN Retention_Status_30d ELSE 0 END) mth8
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-09-30') THEN Retention_Status_30d ELSE 0 END) mth9
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-10-31') THEN Retention_Status_30d ELSE 0 END) mth10
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-11-30') THEN Retention_Status_30d ELSE 0 END) mth11
  , SUM(CASE WHEN FORMAT_DATETIME('%Y-%m', First_Purchase_Date) = FORMAT_DATETIME('%Y-%m','2024-12-31') THEN Retention_Status_30d ELSE 0 END) mth12
--  , SUM(CASE WHEN First_Purchase_Date BETWEEN '2024-01-01' AND '2024-12-31' THEN Retention_Status_30d ELSE 0 END) CHK
FROM 
  `test_250119.User_Profile_Dataset`


-- 4. 사용자 활동 수준과 매출 연관성 분석
-- 활동 수준과 매출 기여도 분석
WITH Activity_Segments AS (
  SELECT 
    User_ID,
    CASE 
      WHEN Total_Activity_Count >= 30 THEN 'High Activity'
      WHEN Total_Activity_Count >= 10 THEN 'Medium Activity'
      ELSE 'Low Activity'
    END AS Activity_Segment
  FROM 
    `test_250119.User_Profile_Dataset`
),
Revenue_Data AS (
  SELECT 
    User_ID,
    SUM(Purchase_Amount) AS Total_Revenue
  FROM 
    `test_250119.Purchase_Dataset`
  GROUP BY 
    User_ID
)
SELECT 
  a.Activity_Segment,
  COUNT(a.User_ID) AS User_Count,
  ROUND(AVG(r.Total_Revenue), 2) AS Avg_Revenue
FROM 
  Activity_Segments a
LEFT JOIN 
  Revenue_Data r
ON 
  a.User_ID = r.User_ID
GROUP BY 
  a.Activity_Segment
ORDER BY 
  User_Count DESC;


-- 5. Cohort 분석_가입 시기별 리텐션 비교_일별
SELECT 
  DATE(Signup_Date) AS Signup_Cohort,
  COUNT(User_ID) AS Total_Users,
  ROUND(AVG(Retention_Status_7d) * 100, 2) AS Avg_Retention_7d,
  ROUND(AVG(Retention_Status_30d) * 100, 2) AS Avg_Retention_30d
FROM 
  `test_250119.User_Profile_Dataset`
GROUP BY 
  Signup_Cohort
ORDER BY 
  Signup_Cohort;


-- 6. Cohort 분석_가입 시기별 리텐션 비교_월별

SELECT 
  FORMAT_DATETIME('%Y-%m', Signup_Date) AS Signup_Cohort,
  COUNT(User_ID) AS Total_Users,
  ROUND(AVG(Retention_Status_7d) * 100, 2) AS Avg_Retention_7d,
  ROUND(AVG(Retention_Status_30d) * 100, 2) AS Avg_Retention_30d
FROM 
  `test_250119.User_Profile_Dataset`
GROUP BY 
  Signup_Cohort
ORDER BY 
  Signup_Cohort;





--- END

