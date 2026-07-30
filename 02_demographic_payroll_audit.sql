FEATURED ANALYSIS 1: Corporate Payroll & Age Cohort Analytics-- 
  Scenario: Unifies cross-facility demographics, maps compensation, executes macro salary benchmarking by Age bracket.



WITH MastersDemographics AS (
SELECT ED.EmployeeID, ED.FirstName, ED.Age
FROM [SQLTUTORIAL].DBO.EMPLOYEEDEMOGRAPHICS AS ED
UNION ALL
SELECT WD.EmployeeID, WD.FirstName, WD.Age
FROM [SQLTUTORIAL].DBO.WarehouseEmployeeDemographics AS WD) , 
AGEGROUPSTABLE AS(
SELECT EmployeeID, Age, 
CASE
WHEN AGE > 40 THEN '40 AND OVER'
ELSE 'UNDER 40'
END AS AGEGROUPS
FROM MastersDemographics), 
AVERAGESALARY AS (
SELECT DISTINCT agegroupstable.AGEGROUPS, avg(es.Salary) over (partition by agegroupstable.agegroups) AS AVERAGESALARYFOREACHAGEGROUP
FROM AGEGROUPSTABLE
LEFT JOIN [SQLTUTORIAL].DBO.EmployeeSalary as es
ON AGEGROUPSTABLE.EMPLOYEEID = ES.EmployeeID)

select *
from AVERAGESALARY


FEATURED ANALYSIS 2: Top Earner Isolation Per Job Title
Scenario: Ranks salaries dynamically within each job title and extracts the #1 highest-paid individual(s).


WITH MasterDemographics AS (
SELECT ED.EmployeeID, ED.Age
FROM [SQLTUTORIAL].DBO.EMPLOYEEDEMOGRAPHICS AS ED
UNION ALL 
SELECT WD.EmployeeID, WD.Age
FROM [SQLTUTORIAL].DBO.WarehouseEmployeeDemographics AS WD), 
RANKPERJOBTITLETABLE AS (
SELECT DENSE_RANK() OVER(PARTITION BY JOBTITLE ORDER BY ES.SALARY DESC) AS RANKPERJOBTITLE, MasterDemographics.EmployeeID, ES.SALARY, ES.JOBTITLE
FROM MasterDemographics
left join [SQLTUTORIAL].dbo.EmployeeSalary AS ES
on masterdemographics.EmployeeID = ES.EmployeeID
where salary is not null)

SELECT*
FROM RANKPERJOBTITLETABLE
where RANKPERJOBTITLE = 1

