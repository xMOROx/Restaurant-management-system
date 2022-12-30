CREATE FUNCTION GetAvgPriceOfMenu(@MenuID int)
    RETURNS money
AS 
    BEGIN
        RETURN (SELECT AVG(Price) FROM Menu WHERE MenuID = @MenuID)
    END
GO