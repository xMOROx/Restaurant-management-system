CREATE FUNCTION calculateBestDiscountTemporary(@ClientID int) RETURNS decimal(3, 2) AS
BEGIN
    RETURN (SELECT max(DiscountValue)
            FROM IndividualClient I
                     JOIN Discounts D ON I.ClientID = D.ClientID
                     JOIN DiscountsVar DV ON DV.VarID = D.VarID
            WHERE DiscountType = 'Temporary'
              AND I.ClientID = @ClientID
              AND AppliedDate <= getdate() <= dateadd(DAY, ValidityPeriod, AppliedDate) -- Temporary Discounts must have endDate
    )
END
GO

CREATE FUNCTION calculateBestDiscountPermanent(@ClientID int) RETURNS decimal(3, 2) AS
BEGIN
    RETURN (SELECT max(DiscountValue)
            FROM IndividualClient I
                     JOIN Discounts D ON I.ClientID = D.ClientID
                     JOIN DiscountsVar DV ON DV.VarID = D.VarID
            WHERE DiscountType = 'Permanent'
              AND I.ClientID = @ClientID)
END
GO

CREATE FUNCTION calculateDiscountForOrder(@OrderId int) RETURNS money AS
BEGIN
    RETURN (SELECT (calculateBestDiscountTemporary(ClientID) + calculateBestDiscountPermanent(ClientID)) *
                   Orders.OrderSum
            FROM Orders
            WHERE OrderID = @OrderId)
END
GO
;


CREATE FUNCTION sumOfMoneySpentIn_Month_Year(@WhichYear int, @WhichMonth int) RETURNS money AS
BEGIN
    RETURN (SELECT sum(OrderSum)
            FROM dbo.Orders
            where @WhichYear = Year(OrderDate)
              and @WhichMonth = Month(OrderDate))
END
GO

