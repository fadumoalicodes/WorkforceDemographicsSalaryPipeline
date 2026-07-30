# WorkforceDemographicsSalaryPipeline

## 📌 Project Overview
This repository contains an end-to-end relational data pipeline engineered in T-SQL. The system dynamically federates and audits distributed corporate workforce datasets (Standard Office vs. Warehouse Logistics Demographics) and maps them against operational compensation profiles. 

The project delivers three distinct business intelligence reporting frameworks, transitioning raw administrative records into highly compressed, executive-level decision matrices.

---

## 🏗️ Relational Schema Blueprint
The pipeline processes the following standardized database schemas and column hierarchies:

### 1. EMPLOYEEDEMOGRAPHICS (Office Facility Records)
* `EmployeeID` (INT) - Primary entity identifier
* `FirstName` (VARCHAR) - Staff first name
* `Age` (INT) - Staff age cohort tracking
* `Gender` (VARCHAR) - Staff gender category

### 2. WarehouseEmployeeDemographics (Logistics Facility Records)
* `EmployeeID` (INT) - Primary entity identifier
* `FirstName` (VARCHAR) - Staff first name
* `Age` (INT) - Staff age cohort tracking
* `Gender` (VARCHAR) - Staff gender category

### 3. EmployeeSalary (Corporate Payroll Records)
* `EmployeeID` (INT) - Foreign key mapping reference
* `JobTitle` (VARCHAR) - Active employment role 
* `Salary` (INT) - Base compensation metric

---

## 🛠️ Technical Skillset Demonstrated
* **Modular Code Architecture:** Leveraging multi-layer chained Common Table Expressions (CTEs) to isolate collection, transformation, and analytical phases.
* **Analytical Window Functions:** Applying `AVG()`, `DENSE_RANK()`, and `ROW_NUMBER()` across partitioned boundaries to compute macro-level metrics without dataset collapse.
* **Relational Set Federation:** Implementing `UNION ALL` sub-blocks to dynamically merge physical database sources into optimized, unified virtual views.
* **Conditional Data Segmentation:** Engineering multi-conditional `CASE` statements to perform real-time, cohort aggregation.
* **Optimized Compression:** Weaponizing the `DISTINCT` operator against partitioned views to condense row-heavy sets into clean summaries.

---

## 📊 Core Data Pipeline Implementation (`02_demographic_payroll_audit.sql`)

### FEATURED ANALYSIS 1: Corporate Payroll & Age Cohort Analytics
* **Business Case:** Unifies cross-facility demographics, maps compensation, and executes macro salary benchmarking by Age bracket, compressing thousands of records into an executive view.

```sql
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

SELECT *
FROM AVERAGESALARY;
```

### FEATURED ANALYSIS 2: Top Earner Isolation Per Job Title
* **Business Case:** Ranks salaries dynamically within each unique job role across the entire enterprise and extracts the #1 highest-paid individual(s) per tier.

```sql
WITH MasterDemographics AS (
SELECT ED.EmployeeID, ED.Age
FROM [SQLTUTORIAL].DBO.EMPLOYEEDEMOGRAPHICS AS ED
UNION ALL 
SELECT WD.EmployeeID, WD.Age
FROM [SQLTUTORIAL].DBO.WarehouseEmployeeDemographics AS WD), 
RANKPERJOBTITLETABLE AS (
SELECT DENSE_RANK() OVER(PARTITION BY JOBTITLE ORDER BY ES.SALARY DESC) AS RANKPERJOBTITLE, MasterDemographics.EmployeeID, ES.SALARY, ES.JOBTITLE
FROM MasterDemographics
LEFT JOIN [SQLTUTORIAL].dbo.EmployeeSalary AS ES
ON masterdemographics.EmployeeID = ES.EmployeeID
WHERE salary IS NOT NULL)

SELECT *
FROM RANKPERJOBTITLETABLE
WHERE RANKPERJOBTITLE = 1;
```

### FEATURED ANALYSIS 3: Gender-Based Youth Roster Tracking
* **Business Case:** Segregates global workforce demographics by gender cohort, orders them strictly by seniority, and isolates the absolute youngest staff members.

```sql
WITH MasterDemographics AS (
SELECT  ED.EmployeeId, ED.Age, ED.Gender
FROM [SQLTUTORIAL].DBO.EMPLOYEEDEMOGRAPHICS AS ED
UNION ALL
SELECT WD.EMPLOYEEID, WD.AGE, WD.GENDER
FROM [SQLTUTORIAL].DBO.WarehouseEmployeeDemographics AS WD ) , 
YOUNGESTPERSONOFEACHGENDER AS (
SELECT DENSE_RANK() OVER ( PARTITION BY GENDER ORDER BY AGE ) AS RANKAGE, MasterDemographics.Gender, MasterDemographics.Age
FROM MasterDemographics
WHERE AGE IS NOT NULL)

SELECT *
FROM YOUNGESTPERSONOFEACHGENDER
WHERE RANKAGE = 1;
```
