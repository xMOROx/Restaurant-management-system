CREATE FUNCTION GetAvgPriceOfMenu(@MenuID int)
    RETURNS money
AS 
    BEGIN
        RETURN (SELECT AVG(Price) FROM Menu WHERE MenuID = @MenuID)
    END
GO

CREATE FUNCTION MenuIsCorrect(@MenuID int)
    RETURNS bit
AS
    BEGIN
        DECLARE @SameItems int 
        SET @SameItems = (SELECT COUNT(*) 
        FROM (
                SELECT ProductID 
                FROM Menu 
                WHERE MenuID = (@MenuID - 1)
                INTERSECT
                SELECT ProductID
                FROM Menu
                WHERE MenuID = @MenuID
        ) OUT)

        DECLARE @minAmountToChange int 
        SET @minAmountToChange = (SELECT COUNT(*) FROM Menu WHERE MenuID = (@MenuID - 1)) / 2
        IF @SameItems <= @minAmountToChange
            BEGIN
                RETURN 1
            END
        RETURN 0
    END
GO