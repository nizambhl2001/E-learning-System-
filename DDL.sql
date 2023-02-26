IF DB_ID('E_learning_System') IS NOT NULL
Drop database E_learning_System
Go
Create database E_learning_System
On primary
	(
	Name=N'E_learning_System_data_1', 
	Filename=N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\E_learning_System_data_1.mdf',
	Size=25mb,
	Maxsize=100mb,
	Filegrowth=5%
	)
Log on
	(
	Name=N'E_learning_System_log_1', 
	Filename=N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\E_learning_System_log_1.ldf',
	Size=25mb,
	Maxsize=100mb,
	Filegrowth=5%
	);
Go
Use E_learning_System
GO

Create table Teachers
		(
		TeachersID int NOT NULL,
		TeachersName varchar(50),
		Qualification varchar(50),
		Email varchar(50),
		City  varchar(50),
		Date_time datetime default CURRENT_TIMESTAMP,
		Primary key(TeachersID)
		);
		GO
Create table Students
		(
		Std_ID int NOT NULL,
		Std_rollNo int,
		Std_Name varchar(50),
		Std_Email varchar(50),
		Std_city  varchar(50),
		DateOfBirth  varchar(50),
		Date_time datetime default CURRENT_TIMESTAMP,
		Primary key(Std_ID)
		);
		GO
Create table Courses 
		(
		CourseID int NOT NULL,
		CourseName  VARCHAR(150),
		CourseFee  INT,
		CourseHour  INT, 
		Date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
		Primary key(CourseID)
		);
		GO
Create table Semesters
		(
		SemesterID int NOT NULL,
		SemesterName varchar(50),
		Date_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
		Primary key(SemesterID)
		);											
		GO
Create table Feedbacks
		(
		FeedbackID int NOT NULL,
		FeedbackText VARCHAR(350),
		Date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
		Primary key(FeedbackID)
		);
		GO	
CREATE TABLE Reports
		(
		ReportID int NOT NULL IDENTITY,
		TeachersID int NOT NULL FOREIGN KEY REFERENCES Teachers(TeachersID),
		Std_ID int NOT NULL FOREIGN KEY REFERENCES Students(Std_ID),
		CourseID int NOT NULL FOREIGN KEY REFERENCES Courses(CourseID),
		SemesterID int NOT NULL FOREIGN KEY REFERENCES Semesters(SemesterID),
		FeedbackID int NOT NULL FOREIGN KEY REFERENCES Feedbacks(FeedbackID),
		Primary key(ReportID)
		);
		GO

--------------Clustered Index---------------

Create clustered Index IX_Std_roll_age
On Students (Std_rollNo asc,DateOfBirth desc)
Go

-------------Nonclustered Index-------------

Create Nonclustered Index IX_Std_name
On Students(Std_Name)
Go

---------------view with encryption---------------
create view QuickReports 
with encryption
as
(
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
)
Go
drop view QuickReports 

----------------------------Store procedure--------------------------

-----------------sp_insert-----------------

create proc sp_teachers_in
@TeachersID int,
@TeachersName varchar(50),
@Qualification varchar(50),
@Email varchar(60),
@City varchar(60)
as
begin
insert into Teachers(TeachersID,TeachersName,Qualification,Email,City)
values(@TeachersID,@TeachersName,@Qualification,@Email,@City)
end;
go

exec sp_teachers_in 2,'Shinul Hok','EEE IN CSE','shinul@gmail.com','Barishal'

----------------sp_Update------------------

create proc sp_teachers_up
@TeachersID int,
@TeachersName varchar(50),
@Qualification varchar(50),
@Email varchar(60),
@City varchar(60)
as
update Teachers set TeachersName=@TeachersName
where TeachersID=@TeachersID
go

exec sp_teachers_up 2,'Anisul Islam','EEE IN CSE','shinul@gmail.com','Barishal'

----------------sp_delete--------------------

create proc sp_teachers_del
@TeachersID int,
@TeachersName varchar(50),
@Qualification varchar(50),
@Email varchar(60),
@City varchar(60)
as
begin
delete from Teachers
where TeachersID=@TeachersID
end;
Go

exec sp_teachers_del 2,'Shinul Hok','EEE IN CSE','shinul@gmail.com','Barishal'

----------------one in parameter and one out parameter----------------

create proc sp_feedback_in_out
@FeedbackText nvarchar(20),
@FeedbackCount int output
as
begin
	select @FeedbackCount=count(FeedbackID) 
	from Feedbacks
	where FeedbackText=@FeedbackText
end
Declare @TotalCount int
Execute sp_feedback_in_out
@FeedbackCount = @TotalCount OUT , @FeedbackText = 'good'


----------------CREATE trigger TABLE--------------------

-------------------AFTER TRIGGER------------------

CREATE TRIGGER Courses_DELETE
ON Courses
AFTER DELETE
AS
INSERT INTO CousesArchive
(CourseID, CourseName, CourseFee, CourseHour)
SELECT CourseID, CourseName, CourseFee, CourseHour
FROM Deleted 
go

---------------INSTEAD OF TRIGGER --------------

Create Trigger tr_reports_InsteadOfDelete  
on Reports
instead of delete  
as  
Begin  
Declare @ReportID  int  
Select @ReportID  = Reports.ReportID    
 from Reports  
 join deleted    
 on deleted.ReportID  = Reports.ReportID    
if(@ReportID  is NULL )    
  Begin    
   Raiserror('Invalid report  ID or report ID not Exists', 16, 1)    
   Return    
  End  
  else   
 Delete Reports   
 from Reports
 join deleted  
 on Reports.ReportID = deleted.ReportID   
End 
GO

-------------------------UDF(User define function)----------------------------

 -------------scalar value function----------

create function fn_semester()
returns int
begin
declare @SemesterID int;
select @SemesterID=count (*)from Semesters;
return @SemesterID;
end;
Go

select* from dbo.fn_semester()


------------ table- value function--------

create function fn_reports()
returns table
return
(
								
	SELECT  t.TeachersName, COUNT(st.Std_Name)'NoOfStudent',c.CourseName,se.SemesterName,f.FeedbackText
	FROM Reports AS r
	JOIN  Teachers t  ON r.TeachersID = t.TeachersID
	JOIN  Students st  ON r.Std_ID = st.Std_ID
	JOIN  Courses c ON r.CourseID = c.CourseID
	JOIN  Semesters se ON r.SemesterID = se.SemesterID
	JOIN  Feedbacks f ON r.FeedbackID = f.FeedbackID
	GROUP BY t.TeachersName ,c.CourseName,se.SemesterName,f.FeedbackText
	HAVING se.SemesterName ='spring'
);
go

select* from dbo.fn_reports()


----------multi statement table-valued function----------

create function fn_semester_temp()

Returns @outTable table(SemesterID int,SemesterName varchar (200))

begin
	insert into @outTable(SemesterID , SemesterName)
	select SemesterID, SemesterName from Semesters;
	return;
end;

select * from dbo.fn_semester_temp()
Go

-----------Global Temporary table------------

create table ##e_learning_Temp
(
	studentid int,
	studentname varchar(50),
	courseName varchar(50)
)
go


		insert into ##e_learning_Temp
		values (1257577,'S.M.Touhid','asp.net');
		go

select * from ##e_learning_Temp

-----------local Temporary table------------

create table #e_learning_Temp

(
	studentid int,
	studentname varchar(50),
	courseName varchar(50)
);
go

					
		insert into #e_learning_Temp
		values (1257584,'Md.Hasan','asp.net');
		go

select * from #e_learning_Temp


--------------------------------------------------END---------------------------------------------

