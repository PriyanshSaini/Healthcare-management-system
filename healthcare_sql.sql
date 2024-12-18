-- DATA ANALYSIS USING SQL ON HealthCare Database 

-- 1.  Counting Total Record in Database
select count(*) from healthcare_dataset;

---- 2. Finding maximum age of patient admitted.
 select max(age) as maximum_age from healthcare_dataset;

 -- 3. Finding Average age of hospitalized patients.
 select avg(age) as avg_age from healthcare_dataset;

 -- 4. Calculating Patients Hospitalized Age-wise from Maximum to Minimum
 select age ,
 count(age) as total
 from healthcare_dataset
 group by age
 order by age desc;

 -- 5. Calculating Maximum Count of patients on basis of total patients hospitalized with respect to age.
 select age ,
 count(age) as total
 from healthcare_dataset
 group by age
 order by total desc, age;

 -- 6. Ranking Age on the number of patients Hospitalized   
 select Age,
 count(age) as Total,
 DENSE_RANK() over (order by count(age) desc, age desc) as Ranking_admitted
 from healthcare_dataset
 group by age;

 -- 7. Finding Count of Medical Condition of patients and lisitng it by maximum no of patients.
 select Medical_Condition, count(Medical_Condition) as Total_patients
 from healthcare_dataset
 group by Medical_Condition
 order by Total_patients desc;

 -- 8. Finding Rank & Maximum number of medicines recommended to patients based on Medical Condition pertaining to them.    
 SELECT 
    Medical_Condition, 
    Medication, 
    COUNT(Medication) AS Total_Medications_to_Patients,
    RANK() OVER (PARTITION BY Medical_Condition ORDER BY COUNT(Medication) DESC) AS Rank_Medicine
FROM healthcare_dataset
GROUP BY Medical_Condition, Medication
ORDER BY Medical_Condition, Rank_Medicine;


--9. Most preffered Insurance Provide  by Patients Hospatilized
 select Insurance_Provider, COUNT(Insurance_Provider) AS Total 
 from healthcare_dataset
 group by Insurance_Provider
 order by Total desc;

-- 10. Find out most preffered Hospital
select Hospital, count(Hospital) as Preffered_Hospital
from healthcare_dataset
group by Hospital,Medical_Condition
 order by Preffered_Hospital desc;

 -- 11. Identifying Average Billing Amount by Medical Condition.
 select Medical_condition, Avg(Billing_Amount) as Avg_Bill
 from healthcare_dataset
 group by Medical_Condition
 order by  Medical_Condition ,Avg_Bill desc;

 -- 12. Finding Billing Amount of patients admitted and number of days spent in respective hospital.
SELECT Medical_Condition, Name, Hospital,
DATEDIFF(DAY,Discharge_date,Date_of_Ad) as Number_of_Days, 
SUM(ROUND(Billing_Amount,2)) OVER(Partition by Hospital ORDER BY Hospital DESC) AS Total_Amount
FROM healthcare_dataset
ORDER BY Medical_Condition;


-- 13. Finding Hospitals which were successful in discharging patients after having test results as 'Normal' with count of days taken to get results to Normal
select Medical_Condition,Hospital, 
DATEDIFF(day,Discharge_date,Date_of_Ad) as No_Of_Days,
Test_Results
from healthcare_dataset
where Test_Results = 'Normal'
order by No_Of_Days desc;

-- 14. Calculate number of blood types of patients which lies betwwen age 20 to 45
SELECT 
    Age, 
    Blood_Type, 
    COUNT(Blood_Type) AS Count_Blood_Type
FROM 
    healthcare_dataset
WHERE 
    Age BETWEEN 20 AND 45
GROUP BY 
    Age, Blood_Type
ORDER BY 
   Blood_Type, Count_Blood_Type DESC;

   -- 15. Find how many of patient are Universal Blood Donor and Universal Blood reciever
SELECT 
    'Universal Donor' AS Type, 
    Blood_Type, 
    COUNT(Blood_Type) AS Count_Blood_Type
FROM 
    healthcare_dataset
WHERE 
    Blood_Type = 'O-'
GROUP BY 
    Blood_Type

UNION ALL

SELECT 
    'Universal Receiver' AS Type, 
    Blood_Type, 
    COUNT(Blood_Type) AS Count_Blood_Type
FROM 
    healthcare_dataset
WHERE 
    Blood_Type = 'AB+'
GROUP BY 
    Blood_Type;


-- 16. Create a procedure to find Universal Blood Donor to an Universal Blood Reciever, with priority to same hospital and afterwards other hospitals

DELIMITER $$

CREATE PROCEDURE Blood_Matcher(IN Name_of_patient VARCHAR(200))
BEGIN
    SELECT 
        D.Name AS Donor_Name, 
        D.Age AS Donor_Age, 
        D.Blood_Type AS Donors_Blood_Type,
        D.Hospital AS Donors_Hospital, 
        R.Name AS Receiver_Name, 
        R.Age AS Receiver_Age, 
        R.Blood_Type AS Receivers_Blood_Type, 
        R.Hospital AS Receivers_Hospital
    FROM 
        healthcare_dataset D
    INNER JOIN 
        healthcare_dataset R 
        ON D.Blood_Type = 'O-' AND R.Blood_Type = 'AB+'
    WHERE 
        (R.Name REGEXP Name_of_patient) 
        AND (D.Age BETWEEN 20 AND 40);
END $$

DELIMITER ;

CALL Blood_Matcher('Matthew Cruz');	-- Enter the Name of patient as Argument

-- 17. Provide a list of hospitals along with the count of patients admitted in the year 2024 AND 2025?
SELECT DISTINCT Hospital, Count(*) as Total_Admitted
FROM healthcare_dataset
WHERE YEAR(Date of Ad) IN (2024, 2025)
GROUP BY 1
ORDER by Total_Admitted DESC; 

-- 18. Create a new column that categorizes patients as high, medium, or low risk based on their medical condition.
SELECT Name, Medical_Condition, Test_Results,
CASE 
		WHEN Test_Results = 'Inconclusive' THEN 'Need More Checks / CANNOT be Discharged'
        WHEN Test_Results = 'Normal' THEN 'Can take discharge, But need to follow Prescribed medications timely' 
        WHEN Test_Results =  'Abnormal' THEN 'Needs more attention and more tests'
        END AS 'Status', Hospital, Doctor
FROM healthcare_dataset
order by Test_Results asc;





