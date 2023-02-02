
USE foodp;

-- TABLE : customer_profile

-- 1. Total records of the dataset
SELECT COUNT(*) AS total_customers
FROM customer_profile;


-- 2. creating view to work with specific columns from the source table
DROP VIEW  IF EXISTS customer_info;

CREATE VIEW customer_info 
AS
SELECT customer_id
	   ,year AS enrollment_year
	   ,annual_income
       ,age
       ,age_group(age) AS age_group
       ,kids
       ,teens
       ,recency
FROM customer_profile;


-- 3.Number of customers enrolled for each year.
SELECT enrollment_year
       ,COUNT(*) AS total_enrolled_customers
FROM customer_info
GROUP BY enrollment_year
ORDER BY enrollment_year;


-- 4. Customers with high annual_income and days since their recent purchase
-- Top 10 customers based on annual_income

DROP VIEW IF EXISTS Top_ten_income;

CREATE VIEW Top_ten_income
AS
SELECT customer_id
       ,enrollment_year
       ,annual_income
       ,age
       ,(kids+teens) AS total_children
       ,recency
FROM customer_info
ORDER BY annual_income DESC
LIMIT 10;

SELECT * FROM Top_ten_income;

-- 5. stored function to categorize the age column and then calculate the customers aggregate measurables of all fields
-- we can call the stored function in sql statement
-- Function to categorize customers based on age - 18-25 young_adult,26-60 adult, above 60 as elders

DROP FUNCTION IF EXISTS age_group;

DELIMITER $$
CREATE FUNCTION age_group(
         age INT)
		
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
      DECLARE age_group VARCHAR(20);
      
      IF age > 60 THEN
             SET age_group = 'Elder';
	  ELSEIF ( age <=60 AND age>25) THEN
			 SET age_group = 'Adult';
	  ELSEIF age <= 25 THEN 
             SET age_group = 'young_adult';
	  END IF;
             RETURN (age_group);
END $$
DELIMITER ;





-- TABLE: product preference

CREATE VIEW product_preferred AS
SELECT ci.annual_income
      ,ci.enrollment_year
      ,ci.age_group
      ,ci.recency
      ,pp.*
FROM product_prefer pp
     JOIN
	 customer_info ci ON pp.customer_id = ci.customer_id;	

 
 
 -- 1. yearly pruchases of products
 SELECT enrollment_year
	  , count(customer_id) AS total_customers
      ,SUM(wines) AS wines_exp
      ,SUM(fruits) AS fruits_exp
      ,SUM(meat_products) AS meat_products_exp
      ,SUM(fish_products) AS fish_products_exp
      ,SUM(sweet_products) AS sweet_products_exp
      ,SUM(gold_products) AS gold_products_exp
FROM product_preferred
GROUP BY enrollment_year
ORDER BY enrollment_year;


-- 2. percent of total expenditure for each age group
CREATE VIEW percent_exp
AS 
SELECT age_group
	  ,count(customer_id) AS total_customers
      ,ROUND(SUM(wines)/SUM(total_exp)*100,2) AS wines_exp
      ,ROUND(SUM(fruits)/SUM(total_exp)*100,2) AS fruits_exp
      ,ROUND(SUM(meat_products)/SUM(total_exp)*100,2) AS meat_products_exp
      ,ROUND(SUM(fish_products)/SUM(total_exp)*100,2) AS fish_products_exp
      ,ROUND(SUM(sweet_products)/SUM(total_exp)*100,2) AS sweet_products_exp
      ,ROUND(SUM(gold_products)/SUM(total_exp)*100,2) AS gold_products_exp
FROM product_preferred
GROUP BY age_group
ORDER BY age_group;


-- wine,meat_products,followed by gold_products are top preferred products among adults and elders. prefer sweets over fruits
-- meat_products are the most preffered products among young adults followed by wines and sweets.Alike adults fruits are least opted products next to gold among young adults


-- 3. using veiw in stored procedure
DELIMITER $$
CREATE PROCEDURE age_group_exp(
          IN In_age_group VARCHAR(30))
BEGIN
     SELECT * FROM percent_exp
     WHERE age_group = In_age_group;
     
END $$
DELIMITER ;

CALL age_group_exp('young_adult');
 
-- TABLE - Camp_complain

SELECT * FROM camp_complain;

SELECT round(sum(campaign1)/count(*)*100,2) AS Camp1_response
	  ,round(sum(campaign2)/count(*)*100,2) AS Camp2_response
      ,round(sum(campaign3)/count(*)*100,2) AS Camp3_response
      ,round(sum(campaign4)/count(*)*100,2) AS Camp4_response
      ,round(sum(campaign5)/count(*)*100,2) AS Camp5_response
      ,round(sum(Targeted_response)/count(*)*100,2) AS targeted_response
FROM camp_complain;


-- No of customers who has zero or more responses for the campaigns

SELECT camp_responses
	  ,count(customer_id) AS Total_responses
FROM camp_complain
GROUP BY Camp_responses;

-- the customer who reponsed in target section but not in any other campaigns

SELECT COUNT(customer_id) AS zero_complaint_target_responses
FROM camp_complain 
WHERE targeted_response = 1
AND (campaign1,campaign2,campaign3,campaign4,campaign5) = (0,0,0,0,0);


