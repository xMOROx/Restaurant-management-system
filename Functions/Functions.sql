CREATE FUNCTION calculateDiscountForOrder(@OrderId int) RETURNS money AS
BEGIN
    RETURN
    SELECT (showBestDiscountPermanent(ClientID) + showBestDiscountTemporary(ClientID)) * Orders.OrderSum
    FROM Orders
    WHERE OrderID = @OrderId
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

