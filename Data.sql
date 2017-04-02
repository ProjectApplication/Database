CREATE DATABASE RoverCafe
GO

USE RoverCafe
GO


CREATE TABLE TableFood
(
	id INT PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Bàn chưa có tên',
	status NVARCHAR(100) NOT NULL DEFAULT N'trống'	-- Tr?ng || Có ngu?i
)
GO

CREATE TABLE Account
(
	UserName NVARCHAR(100) PRIMARY KEY,	
	DisplayName NVARCHAR(100) NOT NULL DEFAULT N'Darkwin',
	PassWord NVARCHAR(1000) NOT NULL DEFAULT 0,
	Type INT NOT NULL  DEFAULT 0 -- 1: admin && 0: staff
)
GO

CREATE TABLE FoodCategory
(
	id NVARCHAR(10)  PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chua d?t tên'
)
GO

CREATE TABLE Food
(
	id NVARCHAR(10)  PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'chưa đặt tên',
	idCategory NVARCHAR(10) NOT NULL,
	price FLOAT NOT NULL DEFAULT 0
	
	FOREIGN KEY (idCategory) REFERENCES dbo.FoodCategory(id)
)
GO

CREATE TABLE Bill
(
	id int IDENTITY PRIMARY KEY,
	DateCheckIn DATETIME NOT NULL DEFAULT GETDATE(),
	idTable INT NOT NULL,
	discount INT NOT NULL
		
	FOREIGN KEY (idTable) REFERENCES dbo.TableFood(id)
)
GO

CREATE TABLE BillInfor
(
	id int IDENTITY  PRIMARY KEY,
	idBill INT NOT NULL,
	idFood NVARCHAR(10) NOT NULL,
	quantity INT NOT NULL DEFAULT 0,
	discount INT NOT NULL DEFAULT 0

	FOREIGN KEY (idBill) REFERENCES dbo.Bill(id),
	FOREIGN KEY (idFood) REFERENCES dbo.Food(id)
)
GO


INSERT INTO dbo.Account
        ( UserName ,
          DisplayName ,
          PassWord ,
          Type
        )
VALUES  ( N'Linh' , -- UserName - nvarchar(100)
          N'Hoai' , -- DisplayName - nvarchar(100)
          N'1' , -- PassWord - nvarchar(1000)
          1  -- Type - int
        )
INSERT INTO dbo.Account
        ( UserName ,
          DisplayName ,
          PassWord ,
          Type
        )
VALUES  ( N'Anh' , -- UserName - nvarchar(100)
          N'Dac' , -- DisplayName - nvarchar(100)
          N'1' , -- PassWord - nvarchar(1000)
          0  -- Type - int
        )
GO
SELECT * FROM dbo.Account

CREATE PROC proc_Login 
@userName nvarchar(100), @passWord nvarchar(100)
AS
BEGIN

    SELECT * FROM dbo.Account WHERE UserName = @userName AND PassWord = @passWord
END
GO



DECLARE @i INT = 0

WHILE @i <= 20
BEGIN
	INSERT dbo.TableFood
        ( id, name, status )
VALUES  ( @i, -- id - int
          N'Bàn '+ CAST(@i AS nvarchar(100)), -- name - nvarchar(100)
          N'Trống'  -- status - nvarchar(100)
          )
	SET @i = @i + 1
END

CREATE PROC proc_GetTableList
AS SELECT * FROM dbo.TableFood
GO


CREATE PROC	proc_GetFoodCategory AS BEGIN
           	                       		SELECT * FROM dbo.FoodCategory
           	                       END
CREATE PROC proc_ShowFoodByFoodCategoryId (@id Varchar(30))
AS 
BEGIN SELECT *FROM dbo.Food WHERE idCategory =@id END
--thủ tục lấy table list

CREATE PROC proc_ShowAllFood
AS
BEGIN SELECT * FROM dbo.Food end