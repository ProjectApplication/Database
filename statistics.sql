USE RoverCafe
-- Thống kê theo tháng

-- Lấy bill theo id
CREATE PROC	proc_getBillId
@idBill varchar(10)
AS
BEGIN
SELECT 	B.id AS N'ID',B.DateCheckIn AS N'Ngày',tb.name AS N'Tên bàn',F.name AS N'Tên Món',BI.quantity AS N'Số lượng',
			(F.price * Bi.quantity) AS N'Giá'
		FROM	dbo.Bill B JOIN dbo.TableFood TB ON B.idTable = tb.id,
		dbo.BillInfo BI,dbo.Food F
WHERE B.id = @idBill AND BI.idBill = B.id  AND BI.idFood = F.id
END
EXEC dbo.proc_getBillId @idBill = '3'

--Lấy doanh thu từ ngày bắt đầu đến kết thúc
CREATE PROC	proc_getSumPriceOfBill
@dateBegin DATE,@dateEnd DATE 
AS
BEGIN
SELECT 	B.id AS N'ID',B.DateCheckIn AS N'Ngày',SUM(dbo.Food.price * BI.quantity)-B.discount AS N'Thành tiền'
		
FROM	dbo.Bill B JOIN dbo.TableFood TB ON B.idTable = tb.id,
		dbo.BillInfo BI,dbo.Food
WHERE B.DateCheckIn >= @dateBegin AND B.DateCheckIn <= @dateEnd
		 AND BI.idBill = B.id  AND BI.idFood = dbo.Food.id
		 GROUP BY B.id,B.DateCheckIn,B.discount
END
EXEC dbo.proc_getSumPriceOfBill  @dateBegin = '2017-01-23', @dateEnd = '2017-12-24'

--Lấy doanh thu theo tháng
DROP	 PROC proc_getSumPriceOfBill

CREATE PROC	proc_BillMonth
@month int, @year int
AS
BEGIN
SELECT 	DAY(B.DateCheckIn) AS N'ID',SUM(BI.quantity * dbo.Food.price)-B.discount AS N'Thành tiền'
		
FROM	dbo.Bill B JOIN dbo.TableFood TB ON B.idTable = tb.id,
		dbo.BillInfo BI,dbo.Food
WHERE MONTH(B.DateCheckIn) = @month AND YEAR(B.DateCheckIn) = @year
		 AND BI.idBill = B.id  AND BI.idFood = dbo.Food.id
		 GROUP BY DAY(B.DateCheckIn),B.discount
END
EXEC dbo.proc_BillMonth @month = N'5', @year = N'2017' -- varchar(10)

--Lấy doanh thu theo năm
CREATE PROC	proc_BillYear
@year int
AS
BEGIN
SELECT 	MONTH(B.DateCheckIn) AS N'ID',SUM(BI.quantity * dbo.Food.price)-B.discount AS N'Thành tiền'
		
FROM	dbo.Bill B JOIN dbo.TableFood TB ON B.idTable = tb.id,
		dbo.BillInfo BI,dbo.Food
WHERE    YEAR(B.DateCheckIn) = @year
		 AND BI.idBill = B.id  AND BI.idFood = dbo.Food.id
GROUP BY MONTH(B.DateCheckIn),B.discount
END
EXEC dbo.proc_BillYear @year = N'2017' -- varchar(10)
DROP	PROC proc_BillYear

--Lấy số lượng của từng món ăn
CREATE PROC proc_Statistics
@dateBegin DATE,@dateEnd DATE 
AS
BEGIN
	SELECT  BI.idFood AS N'ID',F.name AS N'Tên', SUM(BI.quantity) AS 'Số lượng',
		 F.price * SUM(BI.quantity) * (100 - BI.discount) AS N'Thành tiền'
	FROM	dbo.BillInfo BI,dbo.Food F,dbo.Bill B
	WHERE BI.idFood = F.id AND B.id = BI.idBill 
	AND b.DateCheckIn >= @dateBegin AND b.DateCheckIn <= @dateEnd
	GROUP BY F.name,f.price,BI.discount,BI.idFood
END
EXEC dbo.proc_Statistics @dateBegin = '2017-01-23', @dateEnd = '2017-12-23' -- 
DROP	PROC proc_Statistics 
CREATE PROC proc_GetTableList
AS SELECT * FROM dbo.TableFood
GO
