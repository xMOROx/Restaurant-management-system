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
    SELECT @CategoryID = CategoryID from Category where CategoryName like 'sea food'
    IF EXISTS(
        SELECT * FROM inserted AS I
        INNER JOIN Orders AS O ON O.OrderID = I.OrderID
        INNER JOIN dbo.OrderDetails OD on O.OrderID = OD.OrderID
        INNER JOIN Products P on OD.ProductID = P.ProductID
        INNER JOIN OrdersTakeaways OT on O.TakeawayID = OT.TakeawaysID
        INNER JOIN Reservation R2 on O.ReservationID = R2.ReservationID
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
    DELETE FROM OrderDetails WHERE OrderID in (
        SELECT O.OrderID from Orders O
        INNER JOIN Reservation R2 on R2.ReservationID = O.ReservationID
        WHERE R2.Status = 'cancelled'
    )
END