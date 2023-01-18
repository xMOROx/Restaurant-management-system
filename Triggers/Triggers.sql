-- Sea food trigger 
-- Trigger ten blokuje zamówienia, które ze względu na znajdujące się w nim owoce
-- morza, winno być złożone maksymalnie do poniedziałku poprzedzającego
-- zamówienie.
CREATE TRIGGER SeaFoodCheckMonday
    ON OrderDetails
AFTER INSERT
AS BEGIN
   SET NOCOUNT ON
    DECLARE @CategoryID int
    SELECT @CategoryID = CategoryID FROM Category WHERE LOWER(CategoryName) LIKE 'sea food'
    IF EXISTS(
        SELECT * FROM inserted AS I
            INNER JOIN Orders AS O ON O.OrderID = I.OrderID
            INNER JOIN dbo.OrderDetails OD ON O.OrderID = OD.OrderID
            INNER JOIN Products P ON OD.ProductID = P.ProductID
            INNER JOIN OrdersTakeaways OT ON O.TakeawayID = OT.TakeawaysID
            INNER JOIN Reservation R2 ON O.ReservationID = R2.ReservationID
        WHERE
            (   DATENAME(WEEKDAY, OT.PrefDate) LIKE 'Thursday'
                AND DATEDIFF(DAY, O.OrderDate, OT.PrefDate) <= 2
                AND CategoryID = @CategoryID
            )
            OR
            (
                DATENAME(WEEKDAY, OT.PrefDate) LIKE 'Friday'
                AND DATEDIFF(DAY, O.OrderDate, OT.PrefDate) <= 3
                AND CategoryID = @CategoryID
            )
            OR
            (
                DATENAME(WEEKDAY, OT.PrefDate) LIKE 'Saturday'
                AND DATEDIFF(DAY, O.OrderDate, OT.PrefDate) <= 4
                AND CategoryID = @CategoryID
            )
            OR
            (   DATENAME(WEEKDAY, R2.startDate) LIKE 'Thursday'
                AND DATEDIFF(DAY, O.OrderDate, R2.startDate) <= 2
                AND CategoryID = @CategoryID
            )
            OR
            (
                DATENAME(WEEKDAY, R2.startDate) LIKE 'Friday'
                AND DATEDIFF(DAY, O.OrderDate, R2.startDate) <= 3
                AND CategoryID = @CategoryID
            )
            OR
            (
                DATENAME(WEEKDAY, R2.startDate) LIKE 'Saturday'
                AND DATEDIFF(DAY, O.OrderDate, R2.startDate) <= 4
                AND CategoryID = @CategoryID
            )
        )
        BEGIN;
            THROW 50001, N'Takie zamówienie winno być złożone maksylamnie do poniedziałku poprzedzającego zamówienie.', 1
        END
    END
GO

-- Trigger usuwa szczegóły zamówienia z tabeli OrderDetails, jeżeli powiązana z nim
-- rezerwacja została anulowana przez klienta

CREATE TRIGGER DeleteOrderDetails
ON OrderDetails
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON
    DELETE FROM OrderDetails WHERE OrderID IN (
        SELECT O.OrderID FROM Orders O
            INNER JOIN Reservation R2 ON R2.ReservationID = O.ReservationID
        WHERE LOWER(R2.Status) LIKE 'cancelled' OR LOWER(R2.Status) LIKE 'denied'
    )
    DELETE FROM OrderDetails WHERE OrderID IN (
        SELECT O.OrderID FROM Orders O
        WHERE LOWER(O.OrderStatus) LIKE 'cancelled' OR LOWER(O.OrderStatus) LIKE 'denied'
    )
END

-- Trigger sprawdza czy danie które probujemy dodac do menu jest w bazie w czasie odbioru zamowienia zaznaczone jako dostepne i jest w menu wtedy
CREATE TRIGGER OrderDetailsInsert
ON OrderDetails
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @ProductID int
    DECLARE @OrderID int
    DECLARE @MenuID int
    SELECT @MenuID = MAX(MenuID) from Menu

    SELECT @ProductID = ProductID from inserted
    SELECT @OrderID = OrderID from inserted
    IF EXISTS(SELECT * FROM Products P WHERE P.ProductID = @ProductID AND P.IsAvailable = 0)
        BEGIN;
            THROW 50001, 'Niepoprawne ProductID, Jego IsAvailable to 0 w tabeli Products. ', 1
            ROLLBACK TRANSACTION
        END
    IF NOT EXISTS(SELECT * FROM MenuDetails MD WHERE MD.MenuID = @MenuID AND MD.ProductID = @ProductID)
        BEGIN
            THROW 50001, 'Ten produkt nieznajduje się aktualnie w menu.', 1
            ROLLBACK TRANSACTION
        END
END
GO

-- Sprawdzanie czy pracodawca dodanego pracownika jest firmą

CREATE TRIGGER EmployeeInsert
ON Employees
FOR INSERT
AS
    BEGIN
        DECLARE @ClientID int
        SELECT @ClientID = CompanyID from inserted
        IF NOT EXISTS(SELECT * FROM Companies C where C.ClientID = @ClientID)
            BEGIN;
                THROW 50001, N'Klient o podanym ID nie jest firmą. Nie można dodać pracownika!', 1
                ROLLBACK TRANSACTION
            END
    END
GO

-- Trigger sprawdza czy stolik można dodać do rezerwacji (czy jest wtedy wolny i aktywny)

CREATE TRIGGER addTableToReservationInsertCheck
ON ReservationDetails
FOR INSERT
AS
    BEGIN
        DECLARE @ReservationID int = (SELECT ReservationID FROM inserted)
        DECLARE @TableID int = (SELECT TableID FROM inserted)

        DECLARE @StartReservationDate datetime
        DECLARE @EndReservationDate datetime

        SELECT @StartReservationDate = StartDate, @EndReservationDate = EndDate FROM Reservation R WHERE R.ReservationID = @ReservationID

        DECLARE @TableInUseCountCompany int
        DECLARE @TableInUseCountIndividuals int

        SELECT @TableInUseCountCompany = COUNT(TableID) from Reservation R
            INNER JOIN ReservationCompany RC on R.ReservationID = RC.ReservationID
            INNER JOIN ReservationDetails RD on RC.ReservationID = RD.ReservationID
        WHERE (R.startDate >= @StartReservationDate AND R.endDate <= @EndReservationDate)

        SELECT @TableInUseCountIndividuals = COUNT(TableID) from Reservation R
            INNER JOIN ReservationIndividual RI on R.ReservationID = RI.ReservationID
            INNER JOIN ReservationDetails RD on RI.ReservationID = RD.ReservationID
        WHERE (R.startDate >= @StartReservationDate AND R.endDate <= @EndReservationDate)

        IF @TableInUseCountIndividuals > 0 OR @TableInUseCountCompany > 0
        BEGIN;
            THROW 50200, N'Dany stolik jest używany przez inną rezerwację! ', 1
            ROLLBACK TRANSACTION;
        END

        IF EXISTS(SELECT * FROM Tables T WHERE T.TableID = @TableID AND T.isActive = 0)
            BEGIN;
                THROW 50200, N'Stolik nie jest w użyciu (isActive jest 0)', 1
                ROLLBACK TRANSACTION;
            END
    END
GO

CREATE TRIGGER TablesOnDelete
ON ReservationDetails
FOR DELETE, UPDATE
AS
    BEGIN
        SET NOCOUNT ON
        DECLARE @TableInUseCountCompany int
        DECLARE @TableInUseCountIndividuals int

        SELECT @TableInUseCountCompany = COUNT(*) FROM deleted D
            INNER JOIN ReservationCompany RC ON RC.ReservationID = D.ReservationID
            INNER JOIN Reservation R2 on RC.ReservationID = R2.ReservationID
        WHERE R2.startDate >= GETDATE()

        SELECT @TableInUseCountIndividuals = COUNT(*) FROM deleted D
            INNER JOIN ReservationIndividual RC ON RC.ReservationID = D.ReservationID
            INNER JOIN Reservation R2 on RC.ReservationID = R2.ReservationID
        WHERE R2.startDate >= GETDATE()

        IF @TableInUseCountCompany > 0 OR @TableInUseCountIndividuals > 0
        BEGIN;
            THROW 52000, N'Stolik nie może zostać usunięty lub zmieniony jego status aktywności jeśli jest zarezerwowany', 1
            ROLLBACK TRANSACTION;
        END
    END
GO

-- Trigger sprawdza czy dodana nowa zmienna zniżki Z1 (ilość minimalna zamówień by
-- otrzymać zniżkę) jest prawidłowa (większa od 0)
CREATE TRIGGER Z1TestForNewDiscountVariable
    ON DiscountsVar
    FOR INSERT ,UPDATE
    AS
    BEGIN
        SET NOCOUNT ON
        IF EXISTS(
            SELECT * FROM inserted AS I
            WHERE I.MinimalOrders<=0
            )
        BEGIN
            THROW 52000, N'Nowa zniżka powinna miec dodatni parametr MinimalOrders', 1
        END
    END
GO


CREATE TRIGGER NewMenuIsCorrect
ON MenuDetails
FOR INSERT 
AS
    BEGIN
        DECLARE @MenuID int = (SELECT MenuID FROM inserted)
        DECLARE @PreviousCorrect int = (SELECT Field_value FROM dbo.MenuIsCorrect(@MenuID) WHERE LOWER(Field) LIKE 'previous')
        DECLARE @FollowingCorrect int = (SELECT Field_value FROM dbo.MenuIsCorrect(@MenuID) WHERE LOWER(Field) LIKE 'following')
        DECLARE @HowManyDisplay int = (SELECT COUNT(*) FROM MenuDetails WHERE MenuID = @MenuID) - 1

        IF(@PreviousCorrect = 0)
            BEGIN
                DECLARE @PreviousMenuItemsCount int

                SET @PreviousMenuItemsCount = (SELECT count(*) FROM ShowDuplicatesPreviousMenu (@MenuID))

                IF @PreviousMenuItemsCount > 0
                    BEGIN
                        SELECT TOP (@HowManyDisplay) ProductID, Name, Description FROM ShowDuplicatesPreviousMenu (@MenuID) ORDER BY ProductID;
                    END;

                THROW 50001, N'Zmieniono za małą liczbę dań w aktualnym menu względem wcześniejszego menu!',1
                ROLLBACK TRANSACTION
            END

        IF(@FollowingCorrect = 0)
            BEGIN
                DECLARE @FollowingMenuItemsCount int

                SET @FollowingMenuItemsCount = (SELECT count(*) FROM ShowDuplicatesFollowingMenu(@MenuID))

                IF @FollowingMenuItemsCount > 0
                    BEGIN
                        SELECT TOP (@HowManyDisplay) ProductID, Name, Description FROM ShowDuplicatesFollowingMenu(@MenuID) ORDER BY ProductID;
                    END;

                THROW 50001, N'Zmieniono za małą liczbę dań w aktualnym menu względem przyszłego menu!',1
                ROLLBACK TRANSACTION
            END
    END
go


CREATE TRIGGER CanReservation
    ON Reservation
    AFTER INSERT
AS
    SET NOCOUNT ON
    BEGIN
        DECLARE @LastOrderID int = (SELECT OrderID FROM inserted INNER JOIN Orders O ON O.ReservationID = inserted.ReservationID);
        DECLARE @ClientID int = (SELECT ClientID FROM inserted INNER JOIN Orders O ON O.ReservationID = inserted.ReservationID)
        DECLARE @ReservationID int;

        SELECT @ReservationID = R2.ReservationID FROM Orders
            INNER JOIN Reservation R2 on Orders.ReservationID = R2.ReservationID
        WHERE OrderID = @LastOrderID
        IF @ReservationID IS NOT NULL
        BEGIN;
            DECLARE @MinimalOrders int
            DECLARE @MinimalValue money

            SELECT @MinimalOrders = [Minimal number of orders], @MinimalValue = [Minimal value for orders] FROM CurrentReservationVars

            IF NOT EXISTS(SELECT * FROM dbo.GetClientsOrderedMoreThanXTimes(@MinimalOrders) WHERE ClientID = @ClientID)
            BEGIN
                DECLARE @msg1 varchar(2048) = N'Należy odrzucić dane zamówienie i rezerwację! Klient nie spełnia minimalnej liczby zamówień wynoszącej: ' + @MinimalOrders;
                THROW 52000, @msg1, 1
            END

            IF (SELECT OrderSum FROM OrdersToPrepare WHERE OrderID = @LastOrderID AND ClientID = @ClientID ) >= @MinimalValue
            BEGIN
                DECLARE @msg2 varchar(2048) = N'Należy odrzucić dane zamówienie i rezerwację! Klient nie spełnia minimalnej wartości zamówienia wynoszącej: ' + @MinimalValue;
                THROW 52000, @msg2, 1
            END
        END
    END
GO


CREATE TRIGGER uniqueValuesInCompanies
ON Companies
FOR INSERT, UPDATE
AS 
    BEGIN
        SET NOCOUNT ON
        IF EXISTS(SELECT * FROM inserted I WHERE I.CompanyName IN (SELECT CompanyName FROM Companies WHERE ClientID <> I.ClientID))
        BEGIN
            THROW 52000, N'Nazwa firmy musi być unikalna!', 1
        END
        DECLARE @KRS varchar = (SELECT KRS FROM inserted)
        IF @KRS IS NOT NULL AND EXISTS(SELECT * FROM inserted I WHERE I.KRS IN (SELECT KRS FROM Companies WHERE ClientID <> I.ClientID))
        BEGIN
            THROW 52000, N'KRS musi być unikalny!', 1
        END
        DECLARE @Regon varchar = (SELECT Regon FROM inserted)
        IF @Regon IS NOT NULL AND EXISTS(SELECT * FROM inserted I WHERE I.Regon IN (SELECT Regon FROM Companies WHERE ClientID <> I.ClientID))
        BEGIN
            THROW 52000, N'Regon musi być unikalny!', 1
        END
    END
GO

CREATE TRIGGER UpdateUserDiscounts
ON OrderDetails
AFTER INSERT
AS
    BEGIN
        SET NOCOUNT  ON

        DECLARE @ClientID INT
        DECLARE @MinimalOrders INT
        DECLARE @MinimalAggregateValueTemporary MONEY
        DECLARE @MinimalAggregateValuePermanent MONEY
        SET @ClientID = (SELECT O.ClientID FROM inserted INNER JOIN Orders O ON O.OrderID = inserted.OrderID)

        SELECT @MinimalAggregateValueTemporary = MinimalAggregateValue   FROM DiscountsVar WHERE LOWER(DiscountType) LIKE 'temporary' AND (startDate <= GETDATE() AND (endDate IS NULL OR endDate >= GETDATE()))
        SELECT @MinimalAggregateValuePermanent=MinimalAggregateValue, @MinimalOrders = MinimalOrders FROM DiscountsVar WHERE LOWER(DiscountType) LIKE 'permanent' AND (startDate <= GETDATE() AND (endDate IS NULL OR endDate >= GETDATE()))

        DECLARE @ClientCountOrders int

        SET @ClientCountOrders = (SELECT COUNT(*) FROM OrdersMoreExpensiveThanN(@MinimalAggregateValuePermanent) WHERE ClientID = @ClientID)

        IF @ClientCountOrders >= @MinimalOrders
            BEGIN
--                Add permanent discount
                EXEC addDiscount @ClientID, 'Permanent'
            END
        IF EXISTS(SELECT * FROM GetClientsOrderedMoreThanXValue(@MinimalAggregateValueTemporary) WHERE ClientID = @ClientID)
            BEGIN
--                  Add Temporary discount
                EXEC addDiscount @ClientID, 'Temporary'
            END
    END
GO