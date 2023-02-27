-- Exploratory data analysis

USE foodp;

SHOW TABLES;

SELECT  count(*) FROM customer_profile;
-- the dataset has records for 2205 customers

SELECT avg(Annual_income) 'avg_income'
       ,avg(age) 'avg_age'
       ,ceil(avg(Recency)) 'avg_recency'
FROM customer_profile;
-- a typical customer earns 51.6k bucks per year,is 51 years old, and has recency of 50 days.

SELECT count(*) 
FROM customer_profile
WHERE Annual_income >= (SELECT avg(Annual_income) FROM customer_profile) ;
-- nearly 50% of customers earn income above average.


DESCRIBE customer_profile;
DESCRIBE customer_enrol;

-- a view represents the customer details

DROP VIEW IF EXISTS customer_details;

CREATE VIEW customer_details 
AS
SELECT cp.customer_id
	   ,Annual_income
	   ,Age
       ,kids+teens 'children'
       ,Recency
       ,ce.Enrollment_day
FROM customer_profile cp
     JOIN
     customer_enrol ce ON cp.customer_id = ce.customer_id;

-- yearly and monthly enrollments

SELECT year(Enrollment_day) 'Year'
      ,month(Enrollment_day) 'Month'
      ,count(customer_id) 'customers-enrolled'
FROM customer_details
GROUP BY Year,month
ORDER BY Year DESC;

-- The enrollment of the customers is consistent over the years

DROP PROCEDURE IF EXISTS yearly_customer_acquit;

DELIMITER $$
CREATE PROCEDURE yearly_enrollment()
BEGIN
      SELECT year(Enrollment_day) 'Year'
			,count(customer_id) 'customers-enrolled'
	  FROM customer_details
	  GROUP BY Year
	  ORDER BY Year DESC;
END $$
DELIMITER ;

call yearly_enrollment;
-- 8% of customers enrolled in 1905,50% in 1906, and it decreased to 41% in 1907.

DROP VIEW yearly_customer_acquired;
SHOW TABLES;

-- Average monthly expenditures on various products
SELECT  year(cd.Enrollment_day) 'Year'
        ,month(cd.Enrollment_day) 'Month'
        ,avg(Wines) 'Avg_Wines'
        ,avg(Fruits) 'Avg_Fruits'
        ,avg(Meat_products) 'Avg_Meat_products'
        ,avg(Fish_products) 'Avg_Fish_products'
        ,avg(Sweet_products) 'Avg_Sweet_products'
        ,avg(Gold_products) 'Avg_Gold_products'
        ,avg(Total_exp) 'Avg_total_exp'
FROM customer_details cd
	JOIN 
    product_prefer pp ON cd.customer_id = pp.customer_id
GROUP BY Year,Month
ORDER BY Year;

SELECT  age_group(cd.age) 'age_group'
        ,avg(Wines) 'Avg_Wines'
        ,avg(Fruits) 'Avg_Fruits'
        ,avg(Meat_products) 'Avg_Meat_products'
        ,avg(Fish_products) 'Avg_Fish_products'
        ,avg(Sweet_products) 'Avg_Sweet_products'
        ,avg(Gold_products) 'Avg_Gold_products'
        ,avg(Total_exp) 'Avg_total_exp'
FROM customer_details cd
	JOIN 
    product_prefer pp ON cd.customer_id = pp.customer_id
GROUP BY age_group
ORDER BY Avg_total_exp;


-- Customers spent more on WINES followed by MEAT_PRODUCTS, and then gold,fish_products.Fruits remained as last preference
-- And total_expenditure on products increased.


-- How product preferences varies across different age groups

DROP FUNCTION IF EXISTS age_group;

DELIMITER $$
CREATE FUNCTION age_group(
         age INT)
		
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
      DECLARE age_group VARCHAR(20);
      
      IF age > 60 THEN
             SET age_group = 'elder';
	  ELSEIF ( age <=60 AND age>25) THEN
			 SET age_group = 'Adult';
	  ELSEIF age <= 25 THEN 
             SET age_group = 'young_adult';
	  END IF;
             RETURN (age_group);
END $$
DELIMITER ;


SELECT age_group(age) 'age_group'
	   ,count(cd.customer_id) 'customers'
       ,avg(Annual_income) 'avg_income'
       ,avg(Recency) 'avg_recency'
       ,avg(Total_exp) 'avg_expenditure'
FROM customer_details cd
   JOIN 
   product_prefer pp ON cd.customer_id = pp.customer_id
GROUP BY age_group;

--  approximately 76% of customers are between 25 and 60 years age, 23% are beyond 60 years and less than 25 years constitutes to less than 1%
-- average income varies across ages and is high for older,adult and then yound_adult
-- odler and adults are frequent buyers

-- age & compaign,complain and channels

SELECT age_group(age) 'age_group'
       ,sum(Deal_purchases) 'Deal_purchases'
       ,sum(Web_purchases) 'Web_purchases'
       ,sum(Catalogue_purchases) 'Catalogue_purchases'
       ,sum(Store_purchases) 'Store_purchases'
       ,sum(Web_visits) 'Web_visits'
FROM customer_details cd
   JOIN 
   channel_perform cp ON cd.customer_id = cp.customer_id
GROUP BY age_group;

-- As the data dated to 1970s,the customers had large purchases from stores than any other medium followed by web and catalogues.
-- Deals remained as the last choice for purchasing goods.


-- campaign response and complaints registered

SELECT age_group(age) 'age_group'
	  ,round(sum(campaign1)/count(*)*100,2) AS Campaign1
	  ,round(sum(campaign2)/count(*)*100,2) AS Campaign2
      ,round(sum(campaign3)/count(*)*100,2) AS Campaign3
      ,round(sum(campaign4)/count(*)*100,2) AS Campaign4
      ,round(sum(campaign5)/count(*)*100,2) AS Campaign5
      ,round(sum(Targeted_response)/count(*)*100,2) AS targetedcamp
      ,sum(complain) 'complaints'
FROM customer_details cd
   JOIN 
   camp_complain cc ON cd.customer_id = cc.customer_id
GROUP BY age_group;

-- response is consistent over campaigns from older group. Campaign 3 and 5 have more responses from young adult and adults
-- young adults responsed largely in the targeted campaign while adult and older have equal responses.
-- adults registered more complaints than older.

