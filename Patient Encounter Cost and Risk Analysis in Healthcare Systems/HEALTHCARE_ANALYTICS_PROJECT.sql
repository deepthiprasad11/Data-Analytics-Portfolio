CREATE DATABASE HEALTHCARE_ANALYTICS;
USE HEALTHCARE_ANALYTICS;

SELECT* FROM ENCOUNTERS;
SELECT* FROM organizations;
SELECT * FROM patients;
SELECT * FROM payers;
SELECT * FROM procedures;

---#1 CREATED A DATABASE AND IMPORTED THE TABLES 

---#2 DID SOME DATA ALTERATIONS ADN MODIFICTIONS, THAT IS CHANGING THE DATA TYPES WHICH WERE NECESSARY FOR THE ANALYSIS , AND THERE WERE NO MISSING VALUES AS SUCH

---#3 SQL ANALYSIS TASKS

-----#3a. (a) Evaluating Financial Risk by Encounter Outcome 

SELECT REASONCODE , COUNT(*) AS 'Num_Encounters',
SUM(TOTAL_CLAIM_COST - PAYER_COVERAGE) AS 'TOTAL_UNCOVERED_COST',
AVG(TOTAL_CLAIM_COST - PAYER_COVERAGE) AS 'Avg_Uncovered_Cost'
FROM ENCOUNTERS 
GROUP BY REASONCODE 
ORDER BY TOTAL_UNCOVERED_COST;

-----#3b. (b) Identifying Patients with Frequent High-Cost Encounters
 SELECT * FROM encounters


 SELECT PATIENT , COUNT(*) AS 'Num_Hgh_Cost_Encounters',
 YEAR (START) AS 'YEAR' ,
 SUM (TOTAL_CLAIM_COST) AS 'TOATL_COST' 
 FROM ENCOUNTERS 
 WHERE TOTAL_CLAIM_COST > 10000
 GROUP BY PATIENT , YEAR(START)
 HAVING COUNT(*) > 3
 ORDER BY Num_Hgh_Cost_Encounters;


---#3c. (c) Identifying Risk Factors Based on Demographics and Diagnosis Codes

SELECT TOP 3 REASONCODE, COUNT(*) AS 'Num_Of_Encounters'
FROM encounters 
GROUP BY  REASONCODE 
ORDER BY Num_Of_Encounters;

SELECT E.REASONCODE , P.GENDER , P.RACE , P.ETHNICITY, COUNT(*) AS 'Num_Of_Encounters'
FROM encounters E
JOIN patients P 
ON E.Id = P.Id
WHERE E.REASONCODE IN (
	SELECT TOP 3 REASONCODE
	FROM encounters 
	GROUP BY  REASONCODE 
	ORDER BY COUNT(*) DESC
)
GROUP BY E.REASONCODE , P.GENDER , P.RACE , P.ETHNICITY
ORDER BY E.REASONCODE , Num_Of_Encounters DESC;

---3d. (d) Assessing Payer Contributions for Different Procedure Types
SELECT PR.DESCRIPTION AS Procedure_Description,
SUM(PR.BASE_COST) AS 'Procedure_Base_Cost',
SUM(E.PAYER_COVERAGE) AS 'Total_Payer_Coverage',
SUM(PR.BASE_COST) - SUM(E.PAYER_COVERAGE) AS 'Coverage_Gap'
FROM procedures PR
JOIN encounters E
ON PR.PATIENT = E.PATIENT
GROUP BY PR.DESCRIPTION
ORDER BY Coverage_Gap DESC;


---3e. (e) Identifying Patients with Multiple Procedures Across Encounters
SELECT PR.PATIENT , PR.REASONCODE, COUNT(DISTINCT PR.ENCOUNTER) AS 'Num_Encounter'
FROM procedures PR
WHERE PR.REASONCODE IS NOT NULL AND PR.REASONCODE <> ' '
GROUP BY PR.PATIENT , PR.REASONCODE
HAVING COUNT(DISTINCT PR.ENCOUNTER) > 1
ORDER BY Num_Encounter DESC; 


---3f. (f) Analyzing Patient Encounter Duration

---individual encounters exceeding 24 hrs
SELECT ID AS Encounter_id, ORGANIZATION , ENCOUNTERCLASS , START , STOP , DATEDIFF(HOUR , START , STOP) AS 'Encounter_Duration'
FROM encounters
WHERE DATEDIFF(HOUR , START , STOP) > 24
ORDER BY ORGANIZATION , ENCOUNTERCLASS , Encounter_Duration DESC;

---avg encounter duration for each class
SELECT ORGANIZATION , ENCOUNTERCLASS , AVG(DATEDIFF(HOUR , START , STOP)) AS 'Avg_Encounter_duration'
FROM encounters
GROUP BY ORGANIZATION , ENCOUNTERCLASS
ORDER BY Avg_Encounter_duration DESC;