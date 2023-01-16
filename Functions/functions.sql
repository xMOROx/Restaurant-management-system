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
    [value ordered] > @value
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
            RETURN (SELECT PreviousID FROM (SELECT MI.MenuID, LAG(MenuID) OVER (ORDER BY startDate, endDate) as 'PreviousID' FROM Menu MI) MO WHERE MO.MenuID = @MenuID)
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
                INNER JOIN Menu M on M.MenuID = MD.MenuID
            WHERE MD.MenuID = dbo.GetIdOfFollowingMenu(@MenuID)
                    AND ABS(DATEDIFF(day, (SELECT TOP 1 endDate from Menu inner join MenuDetails D on Menu.MenuID = D.MenuID WHERE D.MenuID = @MenuID), M.startDate)) <= 1)
go

CREATE FUNCTION ShowDuplicatesInPreviousAndFollowingMenuWithID(@MenuID int)
RETURNS table
    AS
        RETURN SELECT MD.MenuID, P.Name, P.Description FROM MenuDetails MD
                INNER JOIN Products P ON P.ProductID = MD.ProductID
                WHERE
                    P.Name IN (SELECT  MI.Name FROM dbo.ShowDuplicatesInPreviousAndFollowingMenu(@MenuID) MI)
                    AND MenuID = dbo.GetIdOfPreviousMenu(@MenuID)
               UNION
               SELECT MD.MenuID, P.Name, P.Description FROM MenuDetails MD
               INNER JOIN Products P ON P.ProductID = MD.ProductID
               INNER JOIN Menu M on M.MenuID = MD.MenuID
               WHERE
                    P.Name IN (SELECT  MI.Name FROM dbo.ShowDuplicatesInPreviousAndFollowingMenu(@MenuID) MI)
                    AND MD.MenuID = dbo.GetIdOfFollowingMenu(@MenuID)
                    AND ABS(DATEDIFF(day, (SELECT TOP 1 endDate from Menu inner join MenuDetails D on Menu.MenuID = D.MenuID WHERE D.MenuID = @MenuID), M.startDate)) <= 1
go


CREATE FUNCTION WhatWasNotInThePreviousAndFollowingMenu(@MenuID int)
    RETURNS TABLE AS RETURN
        SELECT P.ProductID, P.Name, P.Description as 'Product Description', C.CategoryName , C.Description as 'Category Description' FROM Products P
                INNER JOIN Category C on C.CategoryID = P.CategoryID
            WHERE P.ProductID IN
        (SELECT P.ProductID FROM Products PI
         EXCEPT
            (SELECT ProductID FROM MenuDetails MD
                    INNER JOIN Menu M on M.MenuID = MD.MenuID
                WHERE MD.MenuID=dbo.GetIdOfFollowingMenu(@MenuID)
                    AND ABS(DATEDIFF(day, (SELECT TOP 1 endDate from Menu inner join MenuDetails D on Menu.MenuID = D.MenuID WHERE D.MenuID = @MenuID), M.startDate)) <= 1
                )
         EXCEPT
            (SELECT ProductID FROM MenuDetails
                WHERE MenuID=dbo.GetIdOfPreviousMenu(@MenuID) )
         ) AND P.IsAvailable = 1
go

CREATE FUNCTION getNotReservedTablesOnAParticularDay(@Date datetime)
RETURNS TABLE
    AS
        RETURN (SELECT TableID, ChairAmount FROM Tables
                    WHERE TableID NOT IN(SELECT ReservationDetails.TableID FROM ReservationDetails
                                            INNER JOIN ReservationCompany RC ON RC.ReservationID = ReservationDetails.ReservationID
                                            INNER JOIN Reservation R2 ON RC.ReservationID = R2.ReservationID
                                         WHERE
                                            (CAST(@Date AS date) =  CAST(startDate AS date))
                                            AND (CAST(@Date AS date) =  CAST(endDate AS date))
                                            AND (STATUS NOT LIKE 'cancelled' AND STATUS NOT LIKE 'denied')
                                            AND isActive = 1
                                        ) AND isActive = 1
                UNION
                SELECT TableID, ChairAmount FROM Tables
                    WHERE TableID NOT IN(SELECT ReservationDetails.TableID FROM ReservationDetails
                                            INNER JOIN ReservationIndividual RC ON RC.ReservationID = ReservationDetails.ReservationID
                                            INNER JOIN Reservation R2 ON RC.ReservationID = R2.ReservationID
                                          WHERE
                                                (CAST(@Date AS date) =  CAST(startDate AS date))
                                                AND (CAST(@Date AS date) =  CAST(endDate AS date))
                                                AND (
                                                    STATUS NOT LIKE 'cancelled'
                                                    AND STATUS NOT LIKE 'denied'
                                                )
                                                AND isActive = 1
                                        ) AND isActive = 1
               )
GO


CREATE FUNCTION GenerateIndividualClientReport(@ClientID int, @From Date, @To Date)
RETURNS @report TABLE (
                        field NVARCHAR ( 100 ),
                        field_value NVARCHAR ( 100 )
                      )
AS
BEGIN
    IF NOT EXISTS(SELECT * FROM IndividualClient WHERE ClientID = @ClientID)
    BEGIN
        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            N'Błąd' ,
            'Brak takiego klienta indywidualnego!'
        )
       return
    END
    DECLARE @FirstName NVARCHAR (50)
    SET @FirstName = (SELECT FirstName FROM IndividualClient INNER JOIN Person P on IndividualClient.PersonID = P.PersonID WHERE ClientID = @ClientID)

    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'First Name' ,
        @FirstName
    )

    DECLARE @LastName NVARCHAR (50)
    SET @LastName = (SELECT LastName FROM IndividualClient INNER JOIN Person P on IndividualClient.PersonID = P.PersonID WHERE ClientID = @ClientID)

    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Last name' ,
        @LastName
    )

    DECLARE @TotalOrders INT
    SET @TotalOrders = (
        SELECT count (*) FROM Orders
        WHERE ClientID = @ClientID
        AND OrderDate BETWEEN @From AND @To
    )

    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Total orders',
        @TotalOrders
    )

    DECLARE @CancelledOSOrders INT
    SET @CancelledOSOrders = (
        SELECT count (*) FROM Orders
        WHERE ClientID = @ClientID
            AND OrderDate BETWEEN @From AND @To
            AND LOWER(OrderStatus) LIKE 'cancelled'
    )
    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Cancelled orders',
        @CancelledOSOrders
    )

    DECLARE @DeniedOSOrders INT
    SET @DeniedOSOrders = (
        SELECT count (*) FROM Orders
        WHERE ClientID = @ClientID
            AND OrderDate BETWEEN @From AND @To
            AND LOWER(OrderStatus) LIKE 'denied'
    )
    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Denied orders',
        @DeniedOSOrders
    )

    DECLARE @TotalOSOrdersValue MONEY

    SET @TotalOSOrdersValue = (SELECT SUM(OrderSum) FROM Orders
                                WHERE ClientID = @ClientID
                                    AND OrderDate BETWEEN @From AND @To
                                    AND LOWER(OrderStatus) NOT LIKE 'cancelled' AND LOWER(OrderStatus) NOT LIKE 'denied' )
    IF @TotalOSOrdersValue IS NULL
        BEGIN
           SET @TotalOSOrdersValue = 0
        END

    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Total orders value',
        @TotalOSOrdersValue
    )

    DECLARE @TotalTakeAwayOrders INT
    SET @TotalTakeAwayOrders = (
        SELECT COUNT(*) FROM Orders INNER JOIN OrdersTakeaways OT on OT.TakeawaysID = Orders.TakeawayID
                        WHERE ClientID = @ClientID
                        AND OrderDate BETWEEN @From AND @To
                        AND LOWER(OrderStatus) NOT LIKE 'cancelled' AND LOWER(OrderStatus) NOT LIKE 'denied'
        )

    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Executed take away orders' ,
        @TotalTakeAwayOrders
    )

    DECLARE @CancelledTakeAwayOrders INT
    SET @CancelledTakeAwayOrders = (
        SELECT COUNT(*) FROM Orders INNER JOIN OrdersTakeaways OT on OT.TakeawaysID = Orders.TakeawayID
                        WHERE ClientID = @ClientID
                        AND OrderDate BETWEEN @From AND @To
                        AND LOWER(OrderStatus) LIKE 'cancelled'
        )
    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Cancelled take away orders' ,
        @TotalTakeAwayOrders
    )

    DECLARE @DeniedTakeAwayOrders INT
    SET @DeniedTakeAwayOrders = (
        SELECT COUNT(*) FROM Orders INNER JOIN OrdersTakeaways OT on OT.TakeawaysID = Orders.TakeawayID
                        WHERE ClientID = @ClientID
                        AND OrderDate BETWEEN @From AND @To
                        AND LOWER(OrderStatus) LIKE 'denied'
        )
    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Denied take away orders' ,
        @DeniedTakeAwayOrders
    )

    DECLARE @TotalTAOrdersValue MONEY
    SET @TotalTAOrdersValue = (
                SELECT SUM(OrderSum) FROM Orders INNER JOIN OrdersTakeaways OT on OT.TakeawaysID = Orders.TakeawayID
                        WHERE ClientID = @ClientID
                        AND OrderDate BETWEEN @From AND @To
                        AND LOWER(OrderStatus) NOT LIKE 'cancelled' AND LOWER(OrderStatus) NOT LIKE 'denied'
        )

    IF @TotalTAOrdersValue IS NULL
        BEGIN
            SET @TotalTAOrdersValue = 0
        END

    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Total take away orders value' ,
        @TotalTAOrdersValue
    )

    DECLARE @Reservations int
    SET @Reservations = (
            SELECT COUNT(*) FROM ReservationIndividual RI INNER JOIN Reservation R on R.ReservationID = RI.ReservationID
                            WHERE ClientID = @ClientID
                            AND R.startDate BETWEEN @From AND @To
        )

    INSERT @report
    (
        field ,
        field_value
    )
    VALUES
    (
        'Reservations number' ,
        @reservations
    )
    RETURN
END
GO

CREATE FUNCTION GenerateCompanyReport(@CompanyID int, @From Date, @To date)
RETURNS @Report Table (
                        Field NVARCHAR(100),
                        Field_Value NVARCHAR(100)
                      )
AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Companies WHERE ClientID = @CompanyID)
            BEGIN
                INSERT @Report
                (
                    Field ,
                    Field_Value
                )
                VALUES
                (
                    N'Błąd' ,
                    'Brak takiej Firmy!'
                )
                RETURN
            END
        DECLARE @CompanyName NVARCHAR(50)
        SET @CompanyName = (SELECT CompanyName FROM Companies WHERE ClientID = @CompanyID)

        INSERT @Report
        (
            Field,
            Field_Value
        )
        VALUES
        (
            'Company Name',
            @CompanyName
        )

        DECLARE @Nip char(10)
        SET @Nip = (SELECT Nip FROM Companies WHERE ClientID = @CompanyID)

        INSERT @Report
        (
            Field,
            Field_Value
        )
        VALUES
        (
            'NIP',
            @Nip
        )

        DECLARE @KRS char(10)
        SET @KRS = (SELECT KRS FROM Companies WHERE ClientID = @CompanyID)

        IF @KRS IS NULL
            BEGIN
               SET @KRS = ''
            END

        INSERT @Report
        (
            Field,
            Field_Value
        )
        VALUES
        (
            'KRS',
            @KRS
        )

        DECLARE @Regon char(9)
        SET @Regon = (SELECT Regon FROM Companies WHERE ClientID = @CompanyID)

        IF @Regon IS NULL
            BEGIN
               SET @Regon = ''
            END

        INSERT @Report
        (
            Field,
            Field_Value
        )
        VALUES
        (
            'Regon',
            @Regon
        )

        DECLARE @TotalOrders INT
        SET @TotalOrders = (
            SELECT count (*) FROM Orders
            WHERE ClientID = @CompanyID
            AND OrderDate BETWEEN @From AND @To
        )

        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Total orders',
            @TotalOrders
        )

        DECLARE @CancelledOSOrders INT
        SET @CancelledOSOrders = (
            SELECT count (*) FROM Orders
            WHERE ClientID = @CompanyID
                AND OrderDate BETWEEN @From AND @To
                AND LOWER(OrderStatus) LIKE 'cancelled'
        )
        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Cancelled orders',
            @CancelledOSOrders
        )

        DECLARE @DeniedOSOrders INT
        SET @DeniedOSOrders = (
            SELECT count (*) FROM Orders
            WHERE ClientID = @CompanyID
                AND OrderDate BETWEEN @From AND @To
                AND LOWER(OrderStatus) LIKE 'denied'
        )
        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Denied orders',
            @DeniedOSOrders
        )

        DECLARE @TotalOSOrdersValue MONEY

        SET @TotalOSOrdersValue = (SELECT SUM(OrderSum) FROM Orders
                                    WHERE ClientID = @CompanyID
                                        AND OrderDate BETWEEN @From AND @To
                                        AND LOWER(OrderStatus) NOT LIKE 'cancelled' AND LOWER(OrderStatus) NOT LIKE 'denied' )
        IF @TotalOSOrdersValue IS NULL
            BEGIN
               SET @TotalOSOrdersValue = 0
            END

        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Total orders value',
            @TotalOSOrdersValue
        )

        DECLARE @TotalTakeAwayOrders INT
        SET @TotalTakeAwayOrders = (
            SELECT COUNT(*) FROM Orders INNER JOIN OrdersTakeaways OT on OT.TakeawaysID = Orders.TakeawayID
                            WHERE ClientID = @CompanyID
                            AND OrderDate BETWEEN @From AND @To
                            AND LOWER(OrderStatus) NOT LIKE 'cancelled' AND LOWER(OrderStatus) NOT LIKE 'denied'
            )

        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Executed take away orders' ,
            @TotalTakeAwayOrders
        )

        DECLARE @CancelledTakeAwayOrders INT
        SET @CancelledTakeAwayOrders = (
            SELECT COUNT(*) FROM Orders INNER JOIN OrdersTakeaways OT on OT.TakeawaysID = Orders.TakeawayID
                            WHERE ClientID = @CompanyID
                            AND OrderDate BETWEEN @From AND @To
                            AND LOWER(OrderStatus) LIKE 'cancelled'
            )
        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Cancelled take away orders' ,
            @TotalTakeAwayOrders
        )

        DECLARE @DeniedTakeAwayOrders INT
        SET @DeniedTakeAwayOrders = (
            SELECT COUNT(*) FROM Orders INNER JOIN OrdersTakeaways OT on OT.TakeawaysID = Orders.TakeawayID
                            WHERE ClientID = @CompanyID
                            AND OrderDate BETWEEN @From AND @To
                            AND LOWER(OrderStatus) LIKE 'denied'
            )
        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Denied take away orders' ,
            @DeniedTakeAwayOrders
        )

        DECLARE @TotalTAOrdersValue MONEY
        SET @TotalTAOrdersValue = (
                    SELECT SUM(OrderSum) FROM Orders INNER JOIN OrdersTakeaways OT on OT.TakeawaysID = Orders.TakeawayID
                            WHERE ClientID = @CompanyID
                            AND OrderDate BETWEEN @From AND @To
                            AND LOWER(OrderStatus) NOT LIKE 'cancelled' AND LOWER(OrderStatus) NOT LIKE 'denied'
            )

        IF @TotalTAOrdersValue IS NULL
            BEGIN
                SET @TotalTAOrdersValue = 0
            END

        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Total take away orders value' ,
            @TotalTAOrdersValue
        )

        DECLARE @Reservations int
        SET @Reservations = (
                SELECT COUNT(*) FROM ReservationIndividual RI INNER JOIN Reservation R on R.ReservationID = RI.ReservationID
                                WHERE ClientID = @CompanyID
                                AND R.startDate BETWEEN @From AND @To
            )

        INSERT @report
        (
            field ,
            field_value
        )
        VALUES
        (
            'Reservations number' ,
            @reservations
        )
        RETURN
    END
go

CREATE FUNCTION GenerateTableWeeklyReport(@From Date, @To Date)
RETURNS TABLE
AS
    RETURN (
        SELECT
            YEAR(R2.StartDate) AS year,
            DATEPART(iso_week, R2.StartDate) AS week,
            T.TableID AS table_id,
            T.ChairAmount AS table_size,
            COUNT(RD.TableID) AS how_many_times_reserved
        FROM Tables T
            INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
            INNER JOIN ReservationIndividual RI ON RI.ReservationID = RD.ReservationID
            INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
        WHERE
            (
                LOWER(STATUS) NOT LIKE 'cancelled'
                AND LOWER(STATUS) NOT LIKE 'denied'
                AND startDate BETWEEN @From AND @To
            )
        GROUP BY
            YEAR(R2.StartDate),
            DATEPART(iso_week, R2.StartDate),
            T.TableID,
            T.ChairAmount
    UNION
        SELECT
            YEAR(R2.StartDate) AS year,
            DATEPART(iso_week, R2.StartDate) AS week,
            T.TableID AS table_id,
            T.ChairAmount AS table_size,
            COUNT(RD.TableID) AS how_many_times_reserved
        FROM Tables T
            INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
            INNER JOIN ReservationCompany RI ON RI.ReservationID = RD.ReservationID
            INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
        WHERE
            (
                LOWER(STATUS) NOT LIKE 'cancelled'
                AND LOWER(STATUS) NOT LIKE 'denied'
                AND startDate BETWEEN @From AND @To
            )
        GROUP BY
            YEAR(R2.StartDate),
            DATEPART(iso_week, R2.StartDate),
            T.TableID,
            T.ChairAmount
    )
GO

CREATE FUNCTION GenerateTableMonthlyReport(@From Date, @To Date)
RETURNS TABLE
AS
   RETURN (
        SELECT
            YEAR(R2.StartDate) AS year,
            DATEPART(MONTH, R2.StartDate) AS MONTH,
            T.TableID AS table_id,
            T.ChairAmount AS table_size,
            COUNT(RD.TableID) AS how_many_times_reserved
        FROM Tables T
            INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
            INNER JOIN ReservationIndividual RI ON RI.ReservationID = RD.ReservationID
            INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
        WHERE
            (
                LOWER(STATUS) NOT LIKE 'cancelled'
                AND LOWER(STATUS) NOT LIKE 'denied'
                AND startDate BETWEEN @From AND @To
            )
        GROUP BY
            YEAR(R2.StartDate),
            DATEPART(MONTH, R2.StartDate),
            T.TableID,
            T.ChairAmount
    UNION
        SELECT
            YEAR(R2.StartDate) AS year,
            DATEPART(MONTH, R2.StartDate) AS MONTH,
            T.TableID AS table_id,
            T.ChairAmount AS table_size,
            COUNT(RD.TableID) AS how_many_times_reserved
        FROM
            Tables T
            INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
            INNER JOIN ReservationCompany RI ON RI.ReservationID = RD.ReservationID
            INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
        WHERE
            (
                LOWER(STATUS) NOT LIKE 'cancelled'
                AND LOWER(STATUS) NOT LIKE 'denied'
                AND startDate BETWEEN @From AND @To
            )
        GROUP BY
            YEAR(R2.StartDate),
            DATEPART(MONTH, R2.StartDate),
            T.TableID,
            T.ChairAmount
    )
GO

CREATE FUNCTION GenerateReservationReport(@From Date, @To Date)
RETURNS Table
AS
    RETURN (
        SELECT
            O.ClientID AS 'Numer clienta',
            startDate,
            endDate,
            CONVERT(TIME, endDate - startDate, 108) AS 'Czas trwania',
            O.OrderSum,
            O.OrderDate,
            O.OrderCompletionDate,
            OD.Quantity,
            RD.TableID
        FROM Reservation
            INNER JOIN Orders O ON Reservation.ReservationID = O.ReservationID
            INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
            INNER JOIN ReservationCompany RC ON Reservation.ReservationID = RC.ReservationID
            INNER JOIN ReservationDetails RD ON RC.ReservationID = RD.ReservationID
        WHERE
            LOWER(STATUS) NOT LIKE 'denied' AND LOWER(STATUS) NOT LIKE 'cancelled'
            AND startDate BETWEEN @From AND @To
    UNION
        SELECT
            O.ClientID AS 'Numer clienta',
            startDate,
            endDate,
            CONVERT(TIME, endDate - startDate, 108) AS 'Czas trwania',
            O.OrderSum,
            O.OrderDate,
            O.OrderCompletionDate,
            OD.Quantity,
            RD.TableID
        FROM Reservation
            INNER JOIN Orders O ON Reservation.ReservationID = O.ReservationID
            INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
            INNER JOIN ReservationIndividual RC ON Reservation.ReservationID = RC.ReservationID
            INNER JOIN ReservationDetails RD ON RC.ReservationID = RD.ReservationID
        WHERE
            LOWER(STATUS) NOT LIKE 'denied' AND LOWER(STATUS) NOT LIKE 'cancelled'
            AND startDate BETWEEN @From AND @To
    )
GO

CREATE FUNCTION GenerateReservationMonthlyReport(@From Date, @To Date)
RETURNS Table
AS
    RETURN (
        SELECT
            R.ReservationID,
            R.startDate,
            R.endDate,
            R.Status,
            O.ClientID,
            DATEPART(MONTH, cast(O.OrderDate AS DATE)) AS 'Miesiac',
            DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
            count(OD.ProductID) AS 'Liczba zamowionych produktow'
        FROM Reservation R
            INNER JOIN Orders O on R.ReservationID = O.ReservationID
            INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
        WHERE
            LOWER(STATUS) NOT LIKE 'denied' AND LOWER(STATUS) NOT LIKE 'cancelled'
            AND LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
            AND startDate BETWEEN @From AND @To
        GROUP BY
            R.ReservationID,
            R.startDate,
            R.endDate,
            R.Status,
            O.ClientID,
            DATEPART(MONTH, cast(O.OrderDate AS DATE)),
            DATEPART(YEAR, cast(O.OrderDate AS DATE))
    )
GO

CREATE FUNCTION GenerateReservationWeeklyReport(@From Date, @To Date)
RETURNS Table
AS
    RETURN (
        SELECT
            R.ReservationID,
            R.startDate,
            R.endDate,
            R.Status,
            O.ClientID,
            DATEPART(iso_week, cast(O.OrderDate AS DATE)) AS 'Tydzien',
            DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
            count(OD.ProductID) AS 'Liczba zamowionych produktow'
        FROM Reservation R
            INNER JOIN Orders O on R.ReservationID = O.ReservationID
            INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
        WHERE
            LOWER(STATUS) NOT LIKE 'denied' AND LOWER(STATUS) NOT LIKE 'cancelled'
            AND LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
            AND startDate BETWEEN @From AND @To
        GROUP BY
            R.ReservationID,
            R.startDate,
            R.endDate,
            R.Status,
            O.ClientID,
            DATEPART(iso_week, cast(O.OrderDate AS DATE)),
            DATEPART(YEAR, cast(O.OrderDate AS DATE))
        )

GO

CREATE FUNCTION GenerateMenuReport(@MenuID int)
RETURNS @Report Table(
                        Field nvarchar(100),
                        Field_value nvarchar(100)
                     )
AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Menu WHERE MenuID = @MenuID)
            BEGIN
                INSERT @Report (Field, Field_value)
                VALUES (
                            N'Błąd',
                            'Nie ma menu o takim ID'
                       )
                RETURN
            END

        DECLARE @StartDate DATETIME
        DECLARE @EndDate DATETIME

        SET @StartDate = (SELECT startDate FROM Menu WHERE MenuID = @MenuID)
        SET @EndDate = (SELECT endDate FROM Menu WHERE MenuID = @MenuID)

        INSERT @Report (Field, Field_value)
        VALUES (
                    'StartDate',
                    @StartDate
               )

        INSERT @Report (Field, Field_value)
        VALUES (
                    'EndDate',
                    @EndDate
               )

        INSERT @Report (Field, Field_value)
        SELECT Name, ISNULL((SELECT SUM(Quantity) FROM OrderDetails INNER JOIN Orders O on O.OrderID = OrderDetails.OrderID WHERE P.ProductID = OrderDetails.ProductID AND OrderDate BETWEEN @StartDate AND @EndDate ), 0) FROM MenuDetails
            INNER JOIN Products P on P.ProductID = MenuDetails.ProductID
        WHERE MenuID = @MenuID

        RETURN
    END
GO