CREATE DATABASE HR;
USE HR;

SELECT *
FROM Hr_data;

SELECT termdate
FROM Hr_data
ORDER BY termdate DESC;

UPDATE Hr_data
SET termdate = FORMAT(CONVERT (DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

ALTER TABLE Hr_data
ADD new_termdate DATE;

-- Coppy converted time values from termdate to new_termdate

UPDATE Hr_data
SET new_termdate = CASE	
						WHEN termdate IS NOT NULL AND ISDATE (termdate) = 1 THEN CAST (termdate AS DATETIME)
						ELSE NULL 
				   END;

-- Create new column 'age'
ALTER TABLE HR_data
ADD age nvarchar(50);

-- Populate new column with age 
UPDATE Hr_data
SET age = DATEDIFF (YEAR, birthdate, GETDATE());

--------------------------------------------Exploratory Data Analysis----------------------------
--------------------------------------------------Questions--------------------------------------
--1. What's the age distribution in the company?
-- age distribution
SELECT MIN (age) AS youngest,
	   MAX (age) AS oldest
  FROM Hr_data;

-- age distribution by gender
SELECT age_group,
		gender,
		COUNT (*) AS Count 
FROM 
(SELECT 
	CASE 
		WHEN age >= 22 AND age <= 31 THEN '22 to 31'
		WHEN age >= 32 AND age <= 41 THEN '32 to 41'
		WHEN age >= 42 AND age <= 51 THEN '42 to 51'
		ELSE '51+'
	END AS age_group, gender
FROM Hr_data
WHERE new_termdate IS NULL) AS subquery 
GROUP BY age_group, gender 
ORDER BY age_group,gender;

--2. What's the gender breakdown in the company?
SELECT 
	   gender,
	   COUNT (gender) AS Count
  FROM Hr_data
 WHERE new_termdate IS NULL 
 GROUP BY gender
 ORDER BY gender ASC;

-- 3. How does gender vary across departments and job titles?
SELECT department,
	   gender,
	   COUNT (gender) Quantity
  FROM Hr_data
 WHERE new_termdate IS NULL
 GROUP BY gender, department
 ORDER BY department, gender ASC;

 -- job titles
 SELECT department,
		jobtitle,
		gender,
	    COUNT (gender) Quantity
  FROM Hr_data
 WHERE new_termdate IS NULL
 GROUP BY department, jobtitle, gender
 ORDER BY department, jobtitle, gender ASC;

-- 4. What's the race distribution in the company?
SELECT race,
	   COUNT (race) AS Quantity
  FROM Hr_data
 WHERE new_termdate IS NULL
 GROUP BY race
 ORDER BY Quantity DESC;

-- 5. What's the average length of employment in the company?
SELECT AVG (DATEDIFF (year, hire_date, new_termdate)) AS  avg_length_of_employment
  FROM Hr_data
 WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE ();

-- 6. Which department has the highest turnover rate?
SELECT department,
	   total_count,
	   terminated_count,
	   (ROUND ((CAST (terminated_count AS FLOAT)/total_count), 2)) * 100 AS turnover_rate
  FROM 
	(SELECT department,
		   COUNT (*) AS total_count,
		   SUM (CASE
					WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1
					ELSE 0 
				END ) AS terminated_count
	  FROM Hr_data
	 GROUP BY department) AS subquery 
 ORDER BY turnover_rate DESC;

-- 7. What is the tenure distribution for each department?
SELECT department,
	   AVG (DATEDIFF (year, hire_date, new_termdate)) AS  tenure
  FROM Hr_data
 WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE ()
 GROUP BY department
 ORDER BY tenure DESC;

-- 8. How many employees work remotely for each department?
SELECT 
	   location,
	   COUNT (*) AS count_of_employees
  FROM Hr_data
 WHERE new_termdate IS NULL
 GROUP BY location
 ORDER BY count_of_employees DESC;

-- 9. What's the distribution of employees across different states?
SELECT location_state,
	   COUNT (*) AS count_of_employees
  FROM Hr_data
 WHERE new_termdate IS NULL
 GROUP BY location_state
 ORDER BY count_of_employees DESC ;

-- 10. How are job titles distributed in the company?
SELECT jobtitle,
	   COUNT (*) count
  FROM Hr_data
 WHERE new_termdate IS NULL
 GROUP BY jobtitle
 ORDER BY count DESC;


-- 11. How have employee hire counts varied over time?
SELECT hire_year,
	   hires,
	   terminations,
	   (hires - terminations) AS net_change,
	   (ROUND (CAST((hires - terminations) AS FLOAT )/hires, 2))*100 AS percent_hire_change
  FROM 
		(SELECT YEAR (hire_date) AS hire_year,
			   COUNT (*) AS hires,
			   SUM ( CASE 
						WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1
						ELSE 0
					 END ) terminations
		  FROM Hr_data
		 GROUP BY YEAR (hire_date)) AS subquery
  ORDER BY percent_hire_change ASC;
