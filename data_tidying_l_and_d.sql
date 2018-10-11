----------------------------------------------------------------------------------------------
-- Script Name:		data_tidying_l_and_d.sql
-- Description:		Learning how to tidy underlying data in SQL 
-- Author:			Tom Franklin
-- Creation Date:   11/10/2018
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
--//  Process
-- 1. Create temporary table of CLA data (small extract from additional tables https://www.gov.uk/government/statistics/early-years-foundation-stage-profile-results-2016-to-2017)
-- 2. Unpivot the data into a long format 
-- 3. Now use some string matching to create new variables into columns following tidy data principles 
-- 4. Read off tidy data in a great format, using snake_case column headers 

----------------------------------------------------------------------------------------------
--// 1. Create temporary table of CLA data (small extract from additional tables

DROP TABLE #Table1;
CREATE TABLE #Table1
    ([Country_code] varchar(9), [Country_name] varchar(7), [Characteristic] varchar(17), [Characteristic category] varchar(10), [ELIG_girls_17] int, [ELIG_boys_17] int, [ELIG_all_17] int, [AT_LEAST_EXPECTED_girls_17] int, [AT_LEAST_EXPECTED_boys_17] int, [AT_LEAST_EXPECTED_all_17] int, [GOODLEV_girls_17] int, [GOODLEV_boys_17] int, [GOODLEV_all_17] int, [ELIG_girls_FSM_17] int, [ELIG_boys_FSM_17] int, [ELIG_all_FSM_17] int)
;
    
INSERT INTO #Table1
    ([Country_code], [Country_name], [Characteristic], [Characteristic category], [ELIG_girls_17], [ELIG_boys_17], [ELIG_all_17], [AT_LEAST_EXPECTED_girls_17], [AT_LEAST_EXPECTED_boys_17], [AT_LEAST_EXPECTED_all_17], [GOODLEV_girls_17], [GOODLEV_boys_17], [GOODLEV_all_17], [ELIG_girls_FSM_17], [ELIG_boys_FSM_17], [ELIG_all_FSM_17])
VALUES
    ('E92000001', 'England', 'All pupils', 'All pupils', 326827, 343037, 669864, 250147, 212151, 462298, 254061, 219565, 473626, 44391, 47250, 91641),
    ('E92000001', 'England', 'ETHNICGROUP_MAJOR', 'Asian', 34393, 35987, 70380, 25685, 21274, 46959, 26388, 22482, 48870, 3505, 3753, 7258),
    ('E92000001', 'England', 'ETHNICGROUP_MAJOR', 'Black', 16415, 16913, 33328, 12531, 9997, 22528, 12765, 10433, 23198, 3616, 3734, 7350),
    ('E92000001', 'England', 'ETHNICGROUP_MAJOR', 'Chinese', 1605, 1729, 3334, 1258, 1130, 2388, 1290, 1192, 2482, 111, 106, 217),
    ('E92000001', 'England', 'ETHNICGROUP_MAJOR', 'Mixed', 20103, 21298, 41401, 15770, 13604, 29374, 16030, 14056, 30086, 3891, 4134, 8025),
    ('E92000001', 'England', 'ETHNICGROUP_MAJOR', 'White', 239166, 251224, 490390, 185208, 158061, 343269, 187686, 163011, 350697, 31727, 33818, 65545)
;
-- Now take a look at the data before we begin! 
SELECT * FROM #Table1

----------------------------------------------------------------------------------------------
--// 2. Unpivot the data into a long format 

DROP TABLE #Table2;
SELECT * INTO #Table2 FROM (
SELECT u.[Country_code], u.[Country_name], u.[Characteristic], u.[Characteristic category], u.[measure], u.[number] FROM #Table1 t
unpivot (number
		for [measure] in ([ELIG_girls_17], [ELIG_boys_17], [ELIG_all_17], 
		[AT_LEAST_EXPECTED_girls_17], [AT_LEAST_EXPECTED_boys_17], [AT_LEAST_EXPECTED_all_17], 
		[GOODLEV_girls_17], [GOODLEV_boys_17], [GOODLEV_all_17], 
		[ELIG_girls_FSM_17], [ELIG_boys_FSM_17], [ELIG_all_FSM_17])) u
) as q1;

----------------------------------------------------------------------------------------------
--// 3. Now use some string matching to create new variables into columns following tidy data principles 

DROP TABLE #Table3
SELECT * INTO #Table3 FROM (

SELECT *,
case when measure	= 'ELIG_girls_17'  then 'All pupils regardless of progression' 
     when measure   = 'ELIG_boys_17' then 'All pupils regardless of progression'
     when measure   = 'ELIG_all_17' then 'All pupils regardless of progression'  
     when measure	= 'AT_LEAST_EXPECTED_girls_17' then 'Meeting at least epected standards' 
	 when measure	= 'AT_LEAST_EXPECTED_boys_17'  then 'Meeting at least epected standards' 
	 when measure	= 'AT_LEAST_EXPECTED_all_17' then 'Meeting at least epected standards'
	 when measure	= 'GOODLEV_girls_17'then 'Making good levels of development'
	 when measure	= 'GOODLEV_boys_17' then 'Making good levels of development'
	 when measure	= 'GOODLEV_all_17'then 'Making good levels of development'
	 when measure	= 'ELIG_all_FSM_17'then 'Pupils with FSM eligibility'
	 when measure	= 'ELIG_girls_FSM_17'then 'Pupils with FSM eligibility'
	 when measure	= 'ELIG_boys_FSM_17'then 'Pupils with FSM eligibility' end as progression_measure,
case when measure LIKE '%_girls%' THEN 'Girls' 
     when measure LIKE '%_boys%' THEN 'Boys'
	 when measure LIKE '%_all%' THEN 'Total'   end as characteristic_gender,
case when measure LIKE '%_17%' THEN 2017 end as [year]
 FROM #Table2

 ) as q1

 ----------------------------------------------------------------------------------------------
 --// 4. Read off tidy data in a great format, using snake_case column headers 

 SELECT year, 
	 country_code, 
	 country_name, 
	 [Characteristic category] AS characteristic_ethnicity,
	 characteristic_gender, 
	 progression_measure, 
	 number  FROM #Table3








