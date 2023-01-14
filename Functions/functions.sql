CREATE FUNCTION GetAvgPriceOfMenu(@MenuID int) RETURNS money AS BEGIN RETURN (
    SELECT
        AVG(Price)
    FROM
        MenuDetails
    WHERE
        MenuID = @MenuID
) END
GO



CREATE FUNCTION GetMinimumPriceOfMenu(@MenuID int) RETURNS money AS BEGIN RETURN (
        SELECT
            TOP 1 MIN(Price)
        FROM
            MenuDetails
        WHERE
            MenuID = @MenuID
    ) END
GO
CREATE FUNCTION GetMaximumPriceOfMenu(@MenuID int) RETURNS money AS BEGIN RETURN (
        SELECT
            TOP 1 MAX(Price)
        FROM
            MenuDetails
        WHERE
            MenuID = @MenuID
    ) END
GO


CREATE FUNCTION show_taken_tables_from_x_to_y_with_z_chairs(
        @StartDate datetime,
        @EndDate datetime,
        @Chairs int
    ) RETURNS TABLE AS RETURN
SELECT
    T.TableID,
    T.ChairAmount,
    O.ClientID,
    O.OrderID,
    R2.startDate,
    R2.endDate
FROM
    TABLES T
    INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
    INNER JOIN ReservationCompany RC ON RC.ReservationID = RD.ReservationID
    INNER JOIN Reservation R2 ON RC.ReservationID = R2.ReservationID
    INNER JOIN Orders O ON R2.ReservationID = O.ReservationID
WHERE
    R2.startDate >= @StartDate
    AND R2.endDate <= @EndDate
    AND T.ChairAmount = @Chairs
UNION
SELECT
    T.TableID,
    T.ChairAmount,
    O.ClientID,
    O.OrderID,
    R2.startDate,
    R2.endDate
FROM
    TABLES T
    INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
    INNER JOIN ReservationIndividual RC ON RC.ReservationID = RD.ReservationID
    INNER JOIN Reservation R2 ON RC.ReservationID = R2.ReservationID
    INNER JOIN Orders O ON R2.ReservationID = O.ReservationID
WHERE
    R2.startDate >= @StartDate
    AND R2.endDate <= @EndDate
    AND T.ChairAmount = @Chairs
GO


CREATE FUNCTION show_free_tables_from_x_to_y_with_z_chairs(
        @StartDate datetime,
        @EndDate datetime,
        @Chairs int
    ) RETURNS TABLE AS RETURN
SELECT
    T.TableID,
    T.ChairAmount
FROM
    TABLES T
WHERE
    T.TableID NOT IN (
        SELECT
            Q.TableID
        FROM
            show_taken_tables_from_x_to_y_with_z_chairs(@StartDate, @EndDate, @Chairs) Q
    )
    AND T.isActive = 1
    AND ChairAmount = @Chairs
GO


CREATE FUNCTION GetBestMeal(@input int) RETURNS TABLE AS RETURN
SELECT
    DISTINCT TOP (@input) P.Name,
    MMI.times_sold
FROM
    Products P
    INNER JOIN mealMenuInfo MMI ON P.ProductID = MMI.ProductID
ORDER BY
    MMI.times_sold
GO


CREATE FUNCTION GetClientsOrderedMoreThanXTimes(@amount int) RETURNS TABLE AS RETURN
SELECT
    *
FROM
    ClientStatistics
WHERE
    [times ordered] > @amount
GO


CREATE FUNCTION GetClientsOrderedMoreThanXValue(@value float) RETURNS TABLE AS RETURN
SELECT
    *
FROM
    ClientStatistics
WHERE
    [value ordered with discounts] > @value
go


CREATE FUNCTION GetClientsWhoOweMoreThanX(@value int) RETURNS TABLE AS RETURN
SELECT
    ClientID,
    [money to pay]
FROM
    individualClientsWhoNotPayForOrders
WHERE
    [money to pay] > @value
UNION
SELECT
    ClientID,
    [money to pay]
FROM
    companiesWhoNotPayForOrders
WHERE
    [money to pay] > @value
GO
-- Jeżeli zniżka tymczasowa i została użyta to zmień jej pole isUsed na 1

CREATE FUNCTION calculateBestDiscountTemporary(@ClientID int) RETURNS decimal(3, 2)
AS
    BEGIN
        RETURN (SELECT max(DiscountValue) AS 'Discount Value' FROM IndividualClient I
                INNER JOIN Discounts D ON I.ClientID = D.ClientID
                INNER JOIN DiscountsVar DV ON DV.VarID = D.VarID
            WHERE
                DiscountType = 'Temporary'
                AND I.ClientID = @ClientID
                AND isUsed = 0
                AND AppliedDate <= getdate() AND GETDATE() <= dateadd(DAY, ValidityPeriod, AppliedDate))
    END
GO


CREATE FUNCTION calculateBestDiscountPermanent(@ClientID int) RETURNS decimal(3, 2) AS BEGIN RETURN (
        SELECT
            max(DiscountValue) AS 'Value'
        FROM
            IndividualClient I
            JOIN Discounts D ON I.ClientID = D.ClientID
            JOIN DiscountsVar DV ON DV.VarID = D.VarID
        WHERE
            DiscountType = 'Permanent'
            AND I.ClientID = @ClientID
    ) END
GO


CREATE FUNCTION calculateDiscountForOrder(@OrderId int) RETURNS money
AS BEGIN
DECLARE @BestValue decimal(3, 2);
DECLARE @ClientID int;
SET
    @ClientID = (
        SELECT
            ClientID
        FROM
            Orders
        WHERE
            OrderID = @OrderId
    );IF dbo.calculateBestDiscountTemporary(@ClientID) > dbo.calculateBestDiscountPermanent(@ClientID) BEGIN
SET
    @BestValue = dbo.calculateBestDiscountTemporary(@ClientID);END ELSE BEGIN
SET
    @BestValue = dbo.calculateBestDiscountPermanent(@ClientID);END RETURN (
        SELECT
            @BestValue * Orders.OrderSum
        FROM
            Orders
        WHERE
            OrderID = @OrderId
    ) END
GO;

CREATE FUNCTION sumOfMoneySpentIn_Month_Year(@WhichYear int, @WhichMonth int) RETURNS money AS BEGIN RETURN (
        SELECT
            sum(OrderSum)
        FROM
            dbo.Orders
        WHERE
            @WhichYear = Year(OrderDate)
            AND @WhichMonth = MONTH(OrderDate)
    ) END
GO

-- Zwracanie informacji o zamówieniu o podanym indeksie

CREATE FUNCTION GetOrderDetails(@InputOrderID int) RETURNS TABLE
    AS
        RETURN (
        SELECT
            O.OrderID,
            O.ClientID,
            ISNULL(cast(O.TakeawayID as varchar), 'Order not for takeaway') as 'TakeAwayID',
            ISNULL(cast(O.ReservationID as varchar), 'Order is not for reservation') as 'ReservationID',
            ISNULL(cast(O.InvoiceID as varchar), 'Order does not have invoice.') as 'InvoiceID',
            PM.PaymentName,
            PS.PaymentStatusName,
            CONCAT(S.LastName, ' ', S.FirstName) as 'Employee',
            O.OrderSum,
            O.OrderDate,
            ISNULL(convert(varchar, O.OrderCompletionDate, 120), 'Order is pending') as 'OrderCompletionDate',
            O.OrderStatus,
            P.Name,
            (SELECT MD.Price FROM MenuDetails MD INNER JOIN CurrentMenu CM on MD.MenuID = CM.MenuID WHERE MD.ProductID = OD.ProductID) as 'Product Price',
            OD.Quantity
        FROM Orders O
            INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
            INNER JOIN Products P ON P.ProductID = OD.ProductID
            INNER JOIN PaymentMethods PM on O.PaymentMethodID = PM.PaymentMethodID
            INNER JOIN PaymentStatus PS on O.PaymentStatusID = PS.PaymentStatusID
            INNER JOIN Staff S on O.staffID = S.StaffID
        WHERE
            O.OrderID = @InputOrderID
    )
GO

-- Zwracanie informacji o produkcie o podanej nazwie(informacje ile było zamówiony wciągu 14 dni)
CREATE FUNCTION OrderProductWithin14days (@InputProductName nvarchar(150)) RETURNS INT
AS
    BEGIN
     RETURN (
        SELECT
            SUM([O D].Quantity)
        FROM
            OrderDetails AS [O D]
            INNER JOIN Products P ON P.ProductID = [O D].ProductID
            INNER JOIN Orders O ON O.OrderID = [O D].OrderID
        WHERE
            P.Name LIKE @InputProductName
            AND ABS(DATEDIFF(DAY, O.OrderDate, GETDATE())) <= 14
    )
    END
GO

-- Informacje o zamówieniach powyżej ceny X
CREATE FUNCTION OrdersMoreExpensiveThanN (@N int) RETURNS TABLE
AS
    RETURN (
        SELECT
            O.*
        FROM
            Orders AS O
        WHERE
            O.OrderSum > @N
    )
GO

CREATE FUNCTION ShowDuplicatedProductsInXMenuFromYMenu(@MenuFirstID int, @MenuSecondID int)
    RETURNS TABLE
        AS RETURN SELECT max(M.MenuID) as 'MenuID', P.ProductID, P.Name, P.Description FROM Products P
            INNER JOIN (SELECT P1.ProductID, P1.Name, P1.Description
                FROM MenuDetails M1
                    INNER JOIN Products P1 on P1.ProductID = M1.ProductID
                WHERE MenuID = (@MenuSecondID)
                    INTERSECT
                SELECT P2.ProductID, P2.Name, P2.Description
                FROM MenuDetails M2
                    INNER JOIN Products P2 on P2.ProductID = M2.ProductID
                WHERE MenuID = @MenuFirstID) P3
                ON P3.ProductID = P.ProductID
                    INNER JOIN MenuDetails M on P.ProductID = M.ProductID
                GROUP BY P.ProductID, P.Name, P.Description
GO

--helps to make a new menu
CREATE FUNCTION WhatWasNotInTheMenuOfGivenID(@MenuID int)
    RETURNS TABLE AS RETURN
        SELECT P.ProductID, P.Name, P.Description as 'Product Description', P.IsAvailable, C.CategoryName , C.Description as 'Category Description' FROM Products P
                INNER JOIN Category C on C.CategoryID = P.CategoryID
            WHERE P.ProductID IN
        (SELECT ProductID
         FROM Products PI
         EXCEPT
         SELECT ProductID
         FROM MenuDetails
         WHERE MenuID=@MenuID) AND P.IsAvailable = 1
GO

    CREATE FUNCTION MenuIsCorrect(@MenuID int) RETURNS bit AS BEGIN DECLARE @SameItems int
SET
    @SameItems = (
        SELECT
            COUNT(*)
        FROM
            (
                SELECT
                    ProductID
                FROM
                    MenuDetails
                WHERE
                    MenuID = (@MenuID - 1)
                INTERSECT
                SELECT
                    ProductID
                FROM
                    MenuDetails
                WHERE
                    MenuID = @MenuID
            ) OUT
    ) DECLARE @minAmountToChange int
SET
    @minAmountToChange = (
        SELECT
            COUNT(*)
        FROM
            MenuDetails
        WHERE
            MenuID = (@MenuID - 1)
    ) / 2 IF @SameItems <= @minAmountToChange BEGIN RETURN 1 END RETURN 0 END
GO

CREATE FUNCTION GetIdOfFollowingMenu(@MenuID int)
RETURNS int
    AS
        BEGIN
            RETURN (SELECT FollowingID FROM (SELECT MI.MenuID, LEAD(MenuID) OVER (ORDER BY startDate, endDate) as 'FollowingID' FROM Menu MI) MO WHERE MO.MenuID = @MenuID)
        END
    GO

CREATE FUNCTION GetIdOfPreviousMenu(@MenuID int)
RETURNS int
    AS
        BEGIN
            RETURN (SELECT FollowingID FROM (SELECT MI.MenuID, LAG(MenuID) OVER (ORDER BY startDate, endDate) as 'FollowingID' FROM Menu MI) MO WHERE MO.MenuID = @MenuID)
        END
    GO


CREATE FUNCTION ShowDuplicatesInPreviousAndFollowingMenu(@MenuID int)
RETURNS table
AS
    RETURN SELECT P.Name, P.Description FROM MenuDetails MD
                INNER JOIN Products P on P.ProductID = MD.ProductID
            WHERE MenuID = @MenuID
            INTERSECT
            (SELECT P.Name, P.Description FROM MenuDetails MD
                INNER JOIN Products P on P.ProductID = MD.ProductID
            WHERE MenuID = dbo.GetIdOfPreviousMenu(@MenuID)
            UNION
            SELECT P.Name, P.Description FROM MenuDetails MD
                INNER JOIN Products P on P.ProductID = MD.ProductID
            WHERE MenuID = dbo.GetIdOfFollowingMenu(@MenuID))
GO

CREATE FUNCTION ShowDuplicatesInPreviousAndFollowingMenuWithID(@MenuID int)
RETURNS table
    AS
        RETURN SELECT MD.MenuID, P.Name, P.Description FROM MenuDetails MD
                INNER JOIN Products P ON P.ProductID = MD.ProductID
                WHERE
                    P.Name IN (SELECT  MI.Name FROM dbo.ShowDuplicatesInPreviousAndFollowingMenu(@MenuID) MI)
                    AND MenuID IN (SELECT PreviousID FROM (SELECT MI.MenuID, LAG(MenuID) OVER (ORDER BY startDate, endDate) as 'PreviousID' FROM Menu MI) MO WHERE MO.MenuID = @MenuID)
               UNION
               SELECT MD.MenuID, P.Name, P.Description FROM MenuDetails MD
                INNER JOIN Products P ON P.ProductID = MD.ProductID
               WHERE
                    P.Name IN (SELECT  MI.Name FROM dbo.ShowDuplicatesInPreviousAndFollowingMenu(@MenuID) MI)
                    AND MenuID IN (SELECT FollowingID FROM (SELECT MI.MenuID, LEAD(MenuID) OVER (ORDER BY startDate, endDate) as 'FollowingID' FROM Menu MI) MO WHERE MO.MenuID = @MenuID)
go

CREATE FUNCTION WhatWasNotInThePreviousAndFollowingMenu(@MenuID int)
    RETURNS TABLE AS RETURN
        SELECT P.ProductID, P.Name, P.Description as 'Product Description', C.CategoryName , C.Description as 'Category Description' FROM Products P
                INNER JOIN Category C on C.CategoryID = P.CategoryID
            WHERE P.ProductID IN
        (SELECT P.ProductID FROM Products PI
         EXCEPT
            (SELECT ProductID FROM MenuDetails
                WHERE MenuID=dbo.GetIdOfFollowingMenu(@MenuID))
         EXCEPT
            (SELECT ProductID FROM MenuDetails
                WHERE MenuID=dbo.GetIdOfPreviousMenu (@MenuID))
         ) AND P.IsAvailable = 1
GO


