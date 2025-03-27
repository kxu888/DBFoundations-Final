--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: KaiyueXu
-- Desc: This file demonstrates how to design and create; 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2017-01-01,KaiyueXu,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_KaiyueXu')
	 Begin 
	  Alter Database [ITFnd130FinalDB_KaiyueXu] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_KaiyueXu;
	 End
	Create Database ITFnd130FinalDB_KaiyueXu;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_KaiyueXu;

-- Create Tables (Review Module 01)-- 
CREATE TABLE Courses (
    [CourseID] int IDENTITY(1,1) NOT NULL,
    [CourseName] nVARCHAR(100) NOT NULL,
    [CourseStartDate] DATE NULL,
    [CourseEndDate] DATE NULL,
	[CourseStartTime] TIME NULL,
    [CourseEndTime] TIME NULL,
    [CourseDaysOfWeek] nVarchar(100) Null,
    [CourseCurrentPrice] Money Null);
GO

CREATE TABLE Students (
    [StudentID] int IDENTITY(1,1) NOT Null,
	[StudentNumber] nVarchar(100) Null,
    [StudentFirstName] nVarchar(100) Not Null,
    [StudentLastName] nVarchar(100) Not Null,
    [StudentEmail] nVarchar(100) Not Null,
    [StudentPhone] nVarchar(100) Not Null,
    [StudentAddress1] nVarchar(100) Not Null,
    [StudentAddress2] nVarchar(100) Null,
	[StudentCity] nVarchar(100) Not Null,
	[StudentStateCode] nchar(2) Not Null,
	[StudentZipCode] nchar(10) Not Null);
GO

CREATE TABLE Enrollments (
    [EnrollmentID] Int IDENTITY(1,1) Not Null,
    [StudentID] Int Not Null,
    [CourseID] Int Not Null,
    [EnrollmentDateTime] Datetime Not Null,
    [EnrollmentPrice] Money Not Null,
);
GO

-- Add Constraints (Review Module 02) -- 

ALTER TABLE Courses 
ADD CONSTRAINT pkCourses
PRIMARY KEY(CourseID);

ALTER TABLE Courses 
ADD CONSTRAINT ukCourseName
UNIQUE (CourseName);

ALTER TABLE Courses 
ADD CONSTRAINT ckCourseStartDateLessThanCourseEndDate
CHECK(CourseStartDate < CourseEndDate);

ALTER TABLE Courses 
ADD CONSTRAINT ckCourseEndDateMoreThanCourseStartDate
CHECK(CourseEndDate > CourseStartDate);

ALTER TABLE dbo.Courses 
ADD CONSTRAINT ckCourseStartTimeLessThanCourseEndTime
CHECK(CourseStartTime < CourseEndTime);

ALTER TABLE Courses 
ADD CONSTRAINT ckCourseEndTimeMoreThanCourseStartTime
CHECK(CourseEndTime > CourseStartTime);
GO




ALTER TABLE Students 
ADD CONSTRAINT pkStudents
PRIMARY KEY (StudentID);

ALTER TABLE Students 
ADD CONSTRAINT ukStudentEmail
UNIQUE (StudentEmail);

ALTER TABLE Students 
ADD CONSTRAINT ckStudentZipCode
CHECK (StudentZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]');

ALTER TABLE Students
ADD CONSTRAINT ckStudentEmail 
CHECK (StudentEmail LIKE '%_@__%.__%');

ALTER TABLE Students 
ADD CONSTRAINT ckStudentPhone
CHECK (StudentPhone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
GO




ALTER TABLE Enrollments
ADD CONSTRAINT pkEnrollments
PRIMARY KEY (EnrollmentID);

ALTER TABLE Enrollments
ADD CONSTRAINT fkEnrollmentsToStudents
FOREIGN KEY (StudentID) REFERENCES Students(StudentID);

ALTER TABLE Enrollments
ADD CONSTRAINT fkEnrollmentsToCourses
FOREIGN KEY (CourseID) REFERENCES Courses(CourseID);

ALTER TABLE Enrollments 
ADD CONSTRAINT dfEnrollmentDateTime 
DEFAULT GETDATE() FOR EnrollmentDateTime;

ALTER TABLE Enrollments 
ADD CONSTRAINT ckEnrollmentPriceZeroOrHigher 
CHECK (EnrollmentPrice >= 0);
GO


-- Add Views (Review Module 03 and 06) -- 
CREATE  or ALTER VIEW vCourses 
WITH SCHEMABINDING
AS
SELECT CourseID,
	CourseName,
	CourseStartDate,
	CourseEndDate,
	CourseStartTime,
	CourseEndTime,
	CourseCurrentPrice
FROM dbo.Courses;
GO


CREATE  or ALTER VIEW vStudents 
WITH SCHEMABINDING
AS
SELECT StudentID ,
	StudentFirstName,
	StudentLastName,
	StudentEmail,
	StudentPhone,
	StudentAddress1,
	StudentAddress2,
	StudentCity,
	StudentStateCode,
	StudentZipCode
FROM dbo.Students;
GO


CREATE  or ALTER VIEW vEnrollments
WITH SCHEMABINDING
AS
SELECT EnrollmentID,
	CourseID,
	StudentID,
	EnrollmentDateTime,
	EnrollmentPrice
FROM dbo.Enrollments;
GO


CREATE  or ALTER VIEW vStudentCourseEnrollments 
AS
SELECT E.EnrollmentID,
	E.EnrollmentDateTime,
	E.EnrollmentPrice,
	S.StudentID,
	S.StudentFirstName,
	S.StudentLastName,
	S.StudentEmail,
	S.StudentPhone,
	S.StudentAddress1,
	S.StudentAddress2,
	S.StudentCity,
	S.StudentStateCode,
	S.StudentZipCode,
	C.CourseID,
	C.CourseName,
	C.CourseStartDate,
	C.CourseEndDate,
	C.CourseStartTime,
	C.CourseEndTime
FROM dbo.vEnrollments as E
JOIN dbo.vStudents as S 
ON E.StudentID = S.StudentID
JOIN dbo.vCourses as C 
ON E.CourseID = C.CourseID;
GO


--< Test Tables by adding Sample Data >--  
INSERT INTO Courses 
	(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
VALUES 
	('SQL1 - Winter 2017', '1/10/2017', '1/27/2017', '18:00', '20:50', 'T', 399.00),
	('SQL2 - Winter 2017', '1/31/2017', '2/24/2017', '18:00', '20:50', 'T', 399.00);
GO

INSERT INTO Students(
	[StudentNumber], [StudentFirstName], [StudentLastName], [StudentEmail], [StudentPhone], [StudentAddress1], [StudentAddress2], [StudentCity], [StudentStateCode], [StudentZipCode])
VALUES
	('B-Smith-071', 'Bob', 'Smith', 'Bsmith@HipMail.com', '2061112222', '123 Main St.', NULL, 'Seattle', 'WA', '98001'),
	('S-Jones-003', 'Sue', 'Jones', 'SueJones@YaYou.com', '2062314321', '333 1st Ave.', NULL, 'Seattle', 'WA', '98001');
GO

INSERT INTO Enrollments 
	([StudentID], [CourseID], [EnrollmentDateTime], [EnrollmentPrice])
VALUES 
	(2, 1, '2016-12-14', 349.00),
	(2, 2, '2016-12-14', 349.00),
	(1, 1, '2017-01-03', 399.00),
	(1, 2, '2017-01-03', 399);
GO

-- Add Stored Procedures (Review Module 04 and 08) --

CREATE PROCEDURE pInsCourses
(@CourseName nVarchar(100),
@CourseStartDate DATE,
@CourseEndDate DATE,
@CourseStartTime TIME,
@CourseEndTime TIME,
@CourseCurrentPrice Money)

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Courses 
	(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseCurrentPrice)
    VALUES 
	(@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseCurrentPrice);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0 Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO



CREATE PROCEDURE pUpdCourses
(@CourseID INT,
@CourseName nVarchar(100),
@CourseStartDate DATE,
@CourseEndDate DATE,
@CourseStartTime TIME,
@CourseEndTime TIME,
@CourseCurrentPrice Money)

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Courses 
	(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseCurrentPrice)
    VALUES 
	(@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseCurrentPrice);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO


CREATE PROCEDURE pDelCourses
(@CourseID INT,
@CourseName nVarchar(100),
@CourseStartDate DATE,
@CourseEndDate DATE,
@CourseStartTime TIME,
@CourseEndTime TIME,
@CourseCurrentPrice Money)

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Courses 
	(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseCurrentPrice)
    VALUES 
	(@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseCurrentPrice);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO

CREATE PROCEDURE pInsStudents
(@StudentID INT,
@StudentNumber nVarchar(100),
@StudentFirstName nVarchar(100),
@StudentLastName nVarchar(100),
@StudentEmail nVarchar(100),
@StudentPhone nVarchar(100),
@StudentAddress1 nVarchar(100),
@StudentAddress2 nVarchar(100),
@StudentCity nVarchar(100),
@StudentStateCode nchar(2),
@StudentZipCode nchar(10))

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Students 
	(StudentID ,StudentFirstName,StudentLastName,StudentEmail,StudentPhone,StudentAddress1,StudentAddress2,StudentCity,StudentStateCode,StudentZipCode)
    VALUES 
	(@StudentID ,@StudentFirstName,@StudentLastName,@StudentEmail,@StudentPhone,@StudentAddress1,@StudentAddress2,@StudentCity,@StudentStateCode,@StudentZipCode);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO

CREATE PROCEDURE pUpdStudents
(@StudentID INT,
@StudentNumber nVarchar(100),
@StudentFirstName nVarchar(100),
@StudentLastName nVarchar(100),
@StudentEmail nVarchar(100),
@StudentPhone nVarchar(100),
@StudentAddress1 nVarchar(100),
@StudentAddress2 nVarchar(100),
@StudentCity nVarchar(100),
@StudentStateCode nchar(2),
@StudentZipCode nchar(10))

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Students 
	(StudentID ,StudentFirstName,StudentLastName,StudentEmail,StudentPhone,StudentAddress1,StudentAddress2,StudentCity,StudentStateCode,StudentZipCode)
    VALUES 
	(@StudentID ,@StudentFirstName,@StudentLastName,@StudentEmail,@StudentPhone,@StudentAddress1,@StudentAddress2,@StudentCity,@StudentStateCode,@StudentZipCode);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO


CREATE PROCEDURE pDelStudents
(@StudentID INT,
@StudentNumber nVarchar(100),
@StudentFirstName nVarchar(100),
@StudentLastName nVarchar(100),
@StudentEmail nVarchar(100),
@StudentPhone nVarchar(100),
@StudentAddress1 nVarchar(100),
@StudentAddress2 nVarchar(100),
@StudentCity nVarchar(100),
@StudentStateCode nchar(2),
@StudentZipCode nchar(10))

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Students 
	(StudentID ,StudentFirstName,StudentLastName,StudentEmail,StudentPhone,StudentAddress1,StudentAddress2,StudentCity,StudentStateCode,StudentZipCode)
    VALUES 
	(@StudentID ,@StudentFirstName,@StudentLastName,@StudentEmail,@StudentPhone,@StudentAddress1,@StudentAddress2,@StudentCity,@StudentStateCode,@StudentZipCode);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO




CREATE PROCEDURE pInsEnrollments
(@EnrollmentID Int,
@StudentID Int ,
@CourseID Int ,
@EnrollmentDateTime Datetime,
@EnrollmentPrice Money )

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Enrollments
	(EnrollmentID,StudentID,CourseID,EnrollmentDateTime,EnrollmentPrice)
    VALUES 
	(@EnrollmentID,@StudentID,@CourseID,@EnrollmentDateTime,@EnrollmentPrice);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO


CREATE PROCEDURE pUpdEnrollments
(@EnrollmentID Int,
@StudentID Int ,
@CourseID Int ,
@EnrollmentDateTime Datetime,
@EnrollmentPrice Money )

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Enrollments
	(EnrollmentID,StudentID,CourseID,EnrollmentDateTime,EnrollmentPrice)
    VALUES 
	(@EnrollmentID,@StudentID,@CourseID,@EnrollmentDateTime,@EnrollmentPrice);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO

CREATE PROCEDURE pDelEnrollments
(@EnrollmentID Int,
@StudentID Int ,
@CourseID Int ,
@EnrollmentDateTime Datetime,
@EnrollmentPrice Money )

/* Author: <KaiyueXu>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<KaiyueXu>,Created Sproc.
*/

AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    -- Transaction Code --
    INSERT INTO Enrollments
	(EnrollmentID,StudentID,CourseID,EnrollmentDateTime,EnrollmentPrice)
    VALUES 
	(@EnrollmentID,@StudentID,@CourseID,@EnrollmentDateTime,@EnrollmentPrice);
Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
  IF @@TRANCOUNT >0
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
GO


-- Set Permissions --
BEGIN
DENY SELECT,INSERT,UPDATE,DELETE ON [dbo].[Courses] TO PUBLIC;
GRANT SELECT ON[dbo].[vCourses] to PUBLIC;
GRANT EXECUTE ON[dbo].[pInsCourses] to PUBLIC;
GRANT EXECUTE ON[dbo].[pUpdCourses] to PUBLIC;
GRANT EXECUTE ON[dbo].[pDelCourses] to PUBLIC;

DENY SELECT,INSERT,UPDATE,DELETE ON [dbo].[Students] TO PUBLIC;
GRANT SELECT ON[dbo].[vStudents] to PUBLIC;
GRANT EXECUTE ON[dbo].[pInsStudents] to PUBLIC;
GRANT EXECUTE ON[dbo].[pUpdStudents] to PUBLIC;
GRANT EXECUTE ON[dbo].[pDelStudents] to PUBLIC;

DENY SELECT,INSERT,UPDATE,DELETE ON [dbo].[Enrollments] TO PUBLIC;
GRANT SELECT ON[dbo].[vEnrollments] to PUBLIC;
GRANT EXECUTE ON[dbo].[pInsEnrollments] to PUBLIC;
GRANT EXECUTE ON[dbo].[pUpdEnrollments] to PUBLIC;
GRANT EXECUTE ON[dbo].[pDelEnrollments] to PUBLIC;

END
GO


--< Test Sprocs >-- 
DECLARE @Status INT , 
	@NewCourseID INT,
	@NewStudentID INT,
	@NewEnrollmentID INT

Exec @Status = pInsCourses
	@CourseName= 'TestCourse',
	@CourseStartDate= '20170310',
	@CourseEndDate= '20170324' ,
	@CourseStartTime= '18:00:00',
	@CourseEndTime='20:50:00',
	@CourseDaysOfWeek='T',
	@CourseCurrentPrice= $399;
SELECT Case @Status
	WHEN +1 THEN 'Insert to Courses was successful!'
	WHEN -1 THEN 'Insert to Courses was failed! Common Issues: Duplicate Date'
	END AS [Status];
Set @NewCourseID= @@IDENTITY;
SELECT * FROM vCourses WHERE CourseID= @NewCourseID;

Exec @Status = pUpdCourses
	@CourseName= 'TestCourse',
	@CourseStartDate= '20170310',
	@CourseEndDate= '20170324' ,
	@CourseStartTime= '18:00:00',
	@CourseEndTime='20:50:00',
	@CourseDaysOfWeek='T',
	@CourseCurrentPrice= $499;
SELECT Case @Status
	WHEN +1 THEN 'Insert to Courses was successful!'
	WHEN -1 THEN 'Insert to Courses was failed! Common Issues: Duplicate Date'
	END AS [Status];
Set @NewCourseID= @@IDENTITY;
SELECT * FROM vCourses WHERE CourseID= @NewCourseID;

EXEC @Status= pInsStudents
	@StudentNumber= 'T-Est-01',
	@StudentFirstName= 'Test',
	@StudentLastName= 'Student',
	@StudentEmail= 'TestStudent@HipMail.com',
	@StudentPhone= '1112223333',
	@StudentAddress1= '123 Main St',
	@StudentAddress2= Null,
	@StudentCity= 'Seattle',
	@StudentStateCode= 'WA',
	@StudentZipCode='98001'
SELECT Case @Status
	WHEN +1 THEN 'Update was successful!'
	WHEN -1 THEN 'Update failed! Common Issues: Duplicate Date or Foriegn Key Violation'
	END AS [Status];
Set @NewCourseID= @@IDENTITY;
SELECT * FROM vCourses WHERE CourseID= @NewCourseID;

EXEC @Status= pUpdStudents
	@StudentID= @NewStudentID,
	@StudentNumber= 'T-Est-01 Update',
	@StudentFirstName= 'Test',
	@StudentLastName= 'Student',
	@StudentEmail= 'TestStudent@HipMail.com',
	@StudentPhone= '1112223333',
	@StudentAddress1= '123 Main St',
	@StudentAddress2= Null,
	@StudentCity= 'Seattle',
	@StudentStateCode= 'WA',
	@StudentZipCode='98001'
SELECT Case @Status
	WHEN +1 THEN 'Update was successful!'
	WHEN -1 THEN 'Update failed! Common Issues: Duplicate Date or Foriegn Key Violation'
	END AS [Status];
SELECT * FROM vStudents WHERE StudentID= @NewStudentID;


Exec @Status =pUpdEnrollments
	@EnrollmentID= @NewEnrollmentID,
	@StudentID= @NewStudentID,
	@CourseID=@NewCourseID,
	@EnrollmentDateTime='1/03/2017',
	@EnrollmentPrice='$10000.00'
SELECT Case @Status
	WHEN +1 THEN 'Update to Enrollments was successful!'
	WHEN -1 THEN 'Update to Enrollments failed! Common Issues: Duplicate Date or Foriegn Key Violation'
	END AS [Status];
SELECT * FROM vEnrollments WHERE EnrollmentID= @NewEnrollmentID;

SELECT * FROM vStudentCourseEnrollments;


EXEC @Status= pDelEnrollments
	@EnrollmentID= @NewEnrollmentID;
SELECT Case @Status 
	WHEN +1 THEN 'Delete was successful!'
	WHEN -1 THEN 'Delete failed! Common Issues: Foriegn Key Violation'
	END AS [Status];
SELECT * FROM vEnrollments;

Exec @Status=pDelCourses
	@CourseID= @NewCourseID
SELECT Case @Status 
	WHEN +1 THEN 'Delete was successful!'
	WHEN -1 THEN 'Delete failed! Common Issues: Foriegn Key Violation'
	END AS [Status];
SELECT * FROM vCourses;

Exec @Status=pDelStudents
	@StudentID= @NewStudentID
SELECT Case @Status 
	WHEN +1 THEN 'Delete was successful!'
	WHEN -1 THEN 'Delete failed! Common Issues: Foriegn Key Violation'
	END AS [Status];
SELECT * FROM vStudents;
--{ IMPORTANT!!! }--

BEGIN TRY
	DROP TABLE #CurrentNewIDs
END TRY
BEGIN CATCH
End CATCH
GO


Create Table #CurrentNewIDs (IDSource nvarchar(100), IDNumber int)
Insert into #CurrentNewIDs (IDSource, IDNumber) Values ('Courses', ident_current('Courses'))
Insert into #CurrentNewIDs (IDSource, IDNumber) Values ('Students', @@identity)
Insert into #CurrentNewIDs (IDSource, IDNumber) Values ('Enrollments', scope_identity())

go

Select * From #CurrentNewIDs
Declare @NewStudentID int, @NewCourseID int, @NewEnrollmentID int
Select @NewCourseID = IDNumber From #CurrentNewIDs Where IDSource = 'Courses'
Select @NewStudentID = IDNumber From #CurrentNewIDs Where IDSource = 'Students'
Select @NewEnrollmentID = IDNumber From #CurrentNewIDs Where IDSource = 'Enrollments'
Select @NewCourseID, @NewStudentID, @NewEnrollmentID
go

Declare @NewStudentID int, @NewCourseID int, @NewEnrollmentID int  
Select @NewCourseID = CourseID  
From Courses Where CourseName = 'SQL1 - Winter 2017'  

Select @NewStudentID = StudentID  
From Students Where StudentEmail = 'Bsmith@HipMail.com'  

Select @NewEnrollmentID = EnrollmentID  
From Enrollments Where CourseID = @NewCourseID And StudentID = @NewStudentID  

Select @NewCourseID, @NewStudentID, @NewEnrollmentID  

-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/