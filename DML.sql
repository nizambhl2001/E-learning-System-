USE E_learning_System
GO
----INSERT Teachers Table-----
INSERT INTO Teachers(TeachersID,TeachersName,Qualification,Email,City)VALUES
				(1,'Anisul Islam','BSC IN CSE','kabir@gmail.com','Dhaka'),
				(2,'Shinul Hok','EEE IN CSE','shinul@gmail.com','Barishal'),
				(3,'Riyed Khan','English IN CSE','riyed@gmail.com','Barishal'),
				(4,'Jhiko Khan','Bangla','Jhiko@gmail.com','Dhaka'),
				(5,'Jasmin','Math','jasmin@gmail.com','Dhaka');

GO
----INSERT Students Table-----
INSERT INTO Students(Std_ID,Std_rollNo,Std_Name,Std_Email,Std_city,DateOfBirth)VALUES
				(1,'101', 'Nusrat','nusrat@gmail.com','Barishal','2011/4/4'),
				(2,'102', 'Sultan','sultan@gmail.com','Dhaka','2001/4/4'),
				(3,'103', 'Rakib','rakib@gmail.com','Khulna','2000/4/4'),
				(4,'104', 'Joy','joy@gmail.com','Dhaka','2010/4/4'),
				(5,'105', 'jibon','jibon@gmail.com','Barishal','2010/4/4'),
				(6,'106', 'rubal','rubal@gmail.com','Rongpur','2011/4/4'),
				(7,'107', 'champa','chanpa@gmail.com','Barishal','2011/4/4'),
				(8,'108', 'robi','robi@gmail.com','Dhaka','2013/4/4'),
				(9,'109',' Lija','lija@gmail.com','Dhaka','2011/4/4'),
				(10,'110', 'Mayjabin','mayhejabin@gmail.com','Dhaka','2014/4/4'),
				(11,'111', 'Tanvir','tanvie@gmail.com','Rongpur','2013/4/4'),
				(12,'112', 'rupa','rupa@gmail.com','Barishal','2012/4/4'),
				(13,'113', 'joba','joba@gmail.com','Dhaka','2001/4/4'),
				(14,'114', 'Kamal','kamal@gmail.com','Dhaka','2016/4/4');
GO
----INSERT Semesters Table-----
INSERT INTO Semesters(SemesterID,SemesterName)VALUES 
				(1,'Spring'),
				(2,'Summer'),
				(3,'Fall'),
				(4,'Winter');									
GO
----INSERT Feedbacks Table-----
INSERT INTO Feedbacks(FeedbackID,FeedbackText)VALUES
				(1,'Good'),
				(2,'Best'),
				(3,'Better');

GO
----INSERT Courses Table-----
INSERT INTO Courses(CourseID,CourseName,CourseFee,CourseHour)VALUES
				(1, 'Java',      2500,     80),
				(2, 'Spring',    3500,     90),
				(3, 'MSSQL',     25000,    40),
				(4, 'ASP.Net',   3500,     50),
				(5,'Angulor Js', 18000,   45),
				(6, 'Basic Programming',12000,30),
				(7, 'C Programming',12000, 30);

GO
----INSERT Reports Table-----
INSERT INTO Reports(TeachersID,Std_ID,CourseID,SemesterID,FeedbackID)VALUES
				( 1, 1, 1, 1, 3),
				( 1, 2, 2, 2, 3),
				( 1, 3, 3, 3,  2),
				( 1, 4, 3, 4, 2),
				( 2, 5, 6, 1, 3),
				( 2, 6, 6, 2, 3),
				( 2, 7, 5, 3, 3),
				( 2, 8, 5, 4, 3),
				( 3, 9, 1, 1, 2),
				( 3, 10, 2, 2, 2),
				( 3, 11, 3, 3, 2),
				( 3, 12, 4, 4, 2),
				( 4, 12, 4, 4, 2);

GO
---Retrieves Data From on More TABLES---

SELECT *FROM Teachers;
SELECT *FROM Students;
SELECT *FROM Semesters;
SELECT *FROM Feedbacks;
SELECT *FROM Courses;
SELECT *FROM Reports;
gO

--------Inner Join With GROUP BY and HAVING-------

SELECT  t.TeachersName, COUNT(st.Std_Name)'NoOfStudent',c.CourseName,se.SemesterName,f.FeedbackText
FROM Reports AS r
	JOIN  Teachers t  ON r.TeachersID = t.TeachersID
	JOIN  Students st  ON r.Std_ID = st.Std_ID
	JOIN  Courses c ON r.CourseID = c.CourseID
	JOIN  Semesters se ON r.SemesterID = se.SemesterID
	JOIN  Feedbacks f ON r.FeedbackID = f.FeedbackID
GROUP BY t.TeachersName ,c.CourseName,se.SemesterName,f.FeedbackText
HAVING se.SemesterName ='spring';
GO

-----------CTE(Common Table Expression)------------


WITH CTE_Student_Age (Std_Name, DateOfBirth, CurrentDate, Age) AS (
	SELECT    
		s.Std_Name, 
		s.DateOfBirth,
		GETDATE(),
		YEAR(GETDATE()) - YEAR(s.DateOfBirth)
	FROM Students s
	)

	SELECT
		Std_Name, 
		DateOfBirth,
		Age
	FROM 
		CTE_Student_Age
	WHERE
		Age <= 30;

-----------------sub query table---------------

SELECT  t.TeachersName, COUNT(st.Std_Name)'NoOfStudent',c.CourseName,se.SemesterName,f.FeedbackText
FROM Reports AS r
	JOIN  Teachers t  ON r.TeachersID = t.TeachersID
	JOIN  Students st  ON r.Std_ID = st.Std_ID
	JOIN  Courses c ON r.CourseID = c.CourseID
	JOIN  Semesters se ON r.SemesterID = se.SemesterID
	JOIN  Feedbacks f ON r.FeedbackID = f.FeedbackID
	where SemesterName in(select SemesterName
		from [Semesters] 
		where SemesterID=3)
	GROUP BY t.TeachersName ,c.CourseName,se.SemesterName,f.FeedbackText
GO

-------------------------------MERGE-------------------

create table [Courses identity_merge]
			(
			CourseID int not null primary key,
			CourseName varchar(100),
			CourseFee int,
			CourseHour int
			);
			go
------delete marge table ----
drop table [Courses identity_merge]

---------------update existing, add missing-----------------

merge into dbo.[Courses] as c
using dbo.[Courses identity_merge] as co
	on c.CourseID=co.CourseID
when matched then
update set
	c.CourseName=co.CourseName,
	c.CourseFee=co.CourseFee
when not matched then
	insert (CourseID ,CourseName,CourseFee,CourseHour)
	values (co.CourseID ,co.CourseName,co.CourseFee,co.CourseHour);


	select *from [Courses]
	select *from [Courses identity_merge]
	insert into [Courses identity_merge] values (8,'Wahullah',3000,90)
	update [Courses identity_merge] set CourseName='Rahmat' where CourseID=3
go

---------------MERGE  Show---------------------
select * from [Courses identity_merge]

go
------------------------------------Case Function-------------------------------
SELECT Courses.CourseFee'Course Fee',
CASE
WHEN Courses.CourseFee <= 3500 Then 'Minimam'
WHEN Courses.courseFee <= 18000 Then 'Maxmimam'
ELSE 'The Best Offer'
END AS COMMENTS 
FROM Courses
JOIN Reports on Courses.CourseID = Reports.CourseID
go
---------CASE ----------

select cast('01-june-2019' as date)
go
---convert ----------

select datetime =convert(datetime, '01-june-2019 10:00:00')
go
------------------insert---------------
insert into Feedbacks(FeedbackID,FeedbackText)
values (4,'excelent')
go
------------------update---------------
update Feedbacks set FeedbackText='Good'
where FeedbackID=4
go
------------------delete---------------
delete from Feedbacks where FeedbackID=4
go
---------DISTINCT---------
SELECT DISTINCT CourseID FROM Reports
go
----------TOP------------
SELECT TOP 3 * FROM Reports;
go
----------where---------
SELECT * FROM Reports where ReportID = 5
go
------------And------------
SELECT * FROM Reports
WHERE CourseID='3'AND ReportID=3;
go
------------OR----------
SELECT * FROM Reports
WHERE CourseID='3' OR ReportID=3;
go
-----------NOT-----------
SELECT * FROM Courses
WHERE NOT CourseName='asp.net';
go
------------IN------------not in------
SELECT * FROM Courses
WHERE CourseName IN ('asp.net', 'java', 'spring');
go
SELECT * FROM  Courses
WHERE CourseName Not IN ('asp.net', 'java', 'spring');
 go
-------------BETWEEN---------------
SELECT * FROM courses
WHERE CourseFee BETWEEN 1000 AND 3500;
 go
----------LIKE-------------
SELECT * FROM Courses
WHERE CourseName LIKE 'a%';
go
---------------IS NULL-----------
SELECT * FROM Courses
WHERE CourseName is null;
go
-------------IS Not NULL-------------
SELECT * FROM Courses
WHERE CourseName is not null;
 go
----------------ORDER BY----------
SELECT * FROM Courses
order by CourseName desc;
 
SELECT * FROM Courses
order by CourseName asc;
go
-----------------union----
select CourseID from Courses
union
select SemesterID from Semesters
go

----------some aggregate function---------

------------COUNT---------------------
SELECT COUNT(*) as "Number of Rows"
FROM Reports;
------------COUNT---------------------
SELECT COUNT(CourseFee) as [course fee]
FROM Courses;
------------AVG---------------------
SELECT avg(CourseFee) as [course fee]
FROM Courses;
------------SUM---------------------
SELECT sum(CourseFee) as [course fee]
FROM Courses;
------------max--------------------
SELECT max(CourseFee) as [course fee]
FROM Courses;
-------------min--------------------
SELECT min(CourseFee) as [course fee]
FROM Courses;

---------------some operator----------------

-------------ROLLUP--------------------
SELECT COUNT(CourseID) as [ID], CourseFee
FROM Courses
GROUP BY ROLLUP (CourseFee);

-------------grouping sets--------------------
SELECT CourseName, CourseHour, CourseFee
FROM Courses
GROUP BY grouping sets (CourseName, CourseHour, CourseFee);

-------------CUBE--------------------
SELECT CourseName, SUM(CourseFee) FROM Courses
GROUP BY CUBE(CourseName)
ORDER BY CourseName;

 -------------OVER--------------------
SELECT  CourseName, CourseHour,CourseFee, COUNT(*) OVER() as OverColumn
FROM   Courses;

-------- CASE & Convert----------
SELECT CAST(CourseFee AS decimal(17,2)) AS CastAsDecimal,
       CAST(CourseFee AS varchar) AS CastAsVarchar,
       CONVERT(decimal(17,1),CourseFee) AS ConvertToDecimal,
       CONVERT(varchar,CourseFee,1) AS ConvertToVarchar
FROM Courses;

 ----LEN Function-----
SELECT CourseName,LEN(CourseFee) as LengthOfcoursefee
FROM Courses;

----LTRIM Function-----
SELECT LTRIM(' Hello World') as Test;

----RTRIM function-----
SELECT RTRIM('Hello World    ') AS RightTrimmedString;

----SUBSTRING function-----
SELECT SUBSTRING(CourseName, 1, 5) AS ExtractString
FROM Courses;

----------REPLACE  Function --------
SELECT REPLACE('US-Software', 'T', 'M');

---------REVERSE Function -------
SELECT REVERSE('SQL');

-----------CHARINDEX Function ----------
SELECT CHARINDEX('l', 'Ussl') AS Position;

----------PATINDEX Function ---------
SELECT PATINDEX('%ware%', 'Us-Software');

-------LOWER Function --------
SELECT LOWER('SQL');

----------------------------------------------------END----------------------------------------------------


















