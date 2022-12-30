
-- Category add
CREATE PROCEDURE Project.dbo.addCategory @CategoryName nvarchar(50), @Description nvarchar(150) AS
    BEGIN
        SET NOCOUNT ON
            BEGIN TRY
                IF EXISTS(
                    SELECT * FROM Category WHERE @CategoryName = CategoryName
                )
                    BEGIN
                        ;
                        THROW 52000, N'Kategoria juz istnieje!', 1
                    END
                INSERT INTO Project.dbo.Category (CategoryName, Description) VALUES (@CategoryName, @Description)
            END TRY
            BEGIN CATCH
                DECLARE @msg nvarchar(2048) = N'Blad dodania kategorii: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
            END CATCH
    END
GO
-- Category add

-- Modify table size 
CREATE PROCEDURE ModifyTableSize @TableID int, @Size int
AS
    BEGIN
        SET NOCOUNT ON
            BEGIN TRY
                IF NOT EXISTS(SELECT * from Tables where TableID = @TableID)
                    BEGIN;
                        THROW 52000, N'Nie ma takiego stolika.', 1
                    END
                IF @Size < 2
                    BEGIN;
                        THROW 52000, N'Stolik musi mieć przynajmniej 2 miejsca.', 1
                    END
                IF @Size IS NOT NULL
                    BEGIN
                        UPDATE Tables SET ChairAmount = @Size WHERE TableID = @TableID
                    END
            END TRY
            BEGIN CATCH
                DECLARE  @msg nvarchar(2048) = N'Bład edytowania stolika: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
            END CATCH
    END
GO 

-- Modify table size

-- Modify table status

CREATE PROCEDURE ModifyTableStatus @TableID int, @Status bit
AS
    BEGIN
        SET NOCOUNT ON
            BEGIN TRY
                IF NOT EXISTS(SELECT * from Tables where TableID = @TableID)
                    BEGIN;
                        THROW 52000, N'Nie ma takiego stolika.', 1
                    END
                DECLARE @TableStatus bit
                SELECT @TableStatus = isActive from Tables where TableID = @TableID
                IF @TableStatus = @Status
                    BEGIN;
                        THROW 52000, N'Stolik ma już taki status!.', 1
                    END
                IF @Status IS NOT NULL
                    BEGIN
                        UPDATE Tables SET isActive = @Status WHERE TableID = @TableID
                    END
            END TRY
            BEGIN CATCH
                DECLARE  @msg nvarchar(2048) = N'Bład edytowania stolika: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
            END CATCH
    END
GO

-- Modify table status

-- Add table
CREATE PROCEDURE addTable @Size int, @Status bit
AS
    BEGIN
       SET NOCOUNT ON
       BEGIN TRY
           IF @Size < 2
               BEGIN;
                    THROW 52000, N'Stolik musi mieć przynajmniej 2 miejsca.', 1
                END
           DECLARE @TableID INT
           SELECT @TableID = ISNULL(MAX(TableID), 0) + 1 FROM Tables
           INSERT INTO Tables(TableID, ChairAmount, isActive)
           VALUES (@TableID, @Size, @Status)
       END TRY
       BEGIN CATCH
            DECLARE  @msg nvarchar(2048) = N'Bład edytowania stolika: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
       END CATCH
    END
GO
-- Add table

-- Remove table
CREATE PROCEDURE removeTable @TableID int
AS
    BEGIN
        SET NOCOUNT ON
            BEGIN TRY
                IF NOT EXISTS(SELECT * from Tables where TableID = @TableID)
                    BEGIN;
                        THROW 52000, N'Nie ma takiego stolika.', 1
                    END
                DELETE FROM Tables WHERE TableID = @TableID
            END TRY
            BEGIN CATCH
                DECLARE  @msg nvarchar(2048) = N'Bład edytowania stolika: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
            END CATCH
    END
GO
-- Remove table
