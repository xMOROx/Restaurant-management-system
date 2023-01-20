-- Category add
CREATE PROCEDURE addCategory @CategoryName nvarchar(50), @Description nvarchar(150) AS
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
--Modify table size 

--Modifytable status 
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
--Modifytable status 

--Add table 
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
--Add table 
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
--Remove table 

--add city 
CREATE PROCEDURE addCity @CityName varchar(35)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF EXISTS(SELECT * FROM Cities WHERE CityName = @CityName)
            BEGIN
                THROW 52000, 'Takie miasto już istnieje!', 1
            END
            INSERT INTO Cities(CityName) VALUES (@CityName)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania miasta: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
--add city 

--Add address 
CREATE PROCEDURE addAddress
                @Street nvarchar(70),
                @LocalNr varchar(10),
                @PostalCode char(6),
                @CityName nvarchar(35)
AS
    BEGIN
       SET NOCOUNT ON
       BEGIN TRY
            DECLARE @CityID int
            IF NOT EXISTS(SELECT * FROM Cities WHERE CityName LIKE @CityName)
                 BEGIN
                     EXEC addCity @CityName
                 END
            SELECT @CityID = CityID FROM Cities WHERE CityName LIKE @CityName

            IF EXISTS(SELECT * FROM Address WHERE CityID = @CityID AND PostalCode LIKE @PostalCode AND street LIKE @Street AND LocalNr LIKE @LocalNr)
                BEGIN
                    THROW 52000, 'Istnieje już dokładnie taki sam adres w bazie!', 1
                END 
            INSERT INTO Address(CityID, street, LocalNr, PostalCode)
            VALUES (@CityID, @Street, @LocalNr, @PostalCode)
       END TRY
       BEGIN CATCH
           DECLARE  @msg nvarchar(2048) = N'Bład dodania adresu: ' + ERROR_MESSAGE();
           THROW 52000, @msg, 1
       END CATCH
    END
go
--Add address 

--remove address 
CREATE PROCEDURE removeAddress @AddressID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * from Address where AddressID = @AddressID)
                BEGIN;
                    THROW 52000, N'Nie ma takiego adresu.', 1
                END
            DELETE FROM Address WHERE AddressID = @AddressID
        END TRY
        BEGIN CATCH
            DECLARE  @msg nvarchar(2048) = N'Bład usuniecia adresu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
--remove address 
--add person 
CREATE PROCEDURE addPerson @FirstName varchar(70), @LastName varchar(50)
as
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            INSERT INTO Person(LastName, FirstName)
            VALUES(@LastName, @FirstName)
        end try
        begin catch
            DECLARE  @msg nvarchar(2048) = N'Bład dodania Osoby: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        end catch
    end
GO
--add person 
-- remove person 
CREATE PROCEDURE removePerson @PersonID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * from Person where PersonID = @PersonID)
                BEGIN;
                    THROW 52000, N'Nie ma takiej osoby.', 1
                END
            DELETE FROM Person WHERE PersonID = @PersonID
        END TRY
        BEGIN CATCH
            DECLARE  @msg nvarchar(2048) = N'Bład usuniecia osoby: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- remove person --
-- add client 
CREATE PROCEDURE addClient @ClientType varchar(1),
                            @CityName nvarchar(35) = NULL,
                            @Street nvarchar(70) = NULL,
                            @LocalNr varchar(10) = NULL,
                            @PostalCode char(6) = NULL,
                            @AddressID int = NULL,
                            @Phone varchar(14),
                            @Email varchar(100),
                            @FirstName varchar(50) = NULL,
                            @LastName varchar(70) = NULL,
                            @CompanyName nvarchar(50) = NULL,
                            @NIP char(10) = NULL,
                            @KRS char(10) = NULL,
                            @REGON char(9) = NULL
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF (@ClientType NOT LIKE 'C' AND @ClientType NOT LIKE 'I')
            BEGIN;
                THROW 52000, N'Nie ma takiego typu klienta!', 1
            END

            IF EXISTS(SELECT * FROM Clients WHERE Phone LIKE @Phone)
            BEGIN;
                THROW 52000, N'Numer telefonu jest już w bazie', 1
            END

            IF EXISTS(SELECT * FROM Clients WHERE Email LIKE @Email)
            BEGIN;
                THROW 52000,N'Email jest już w bazie',1
            END

            IF @CompanyName IS NOT NULL AND @ClientType LIKE 'C' AND EXISTS( SELECT * FROM Companies WHERE CompanyName LIKE @CompanyName)
            BEGIN;
                THROW 52000, N'Firma jest już w bazie', 1
            END

            IF @KRS IS NOT NULL AND @ClientType LIKE 'C' AND EXISTS( SELECT * FROM Companies WHERE KRS LIKE @KRS)
            BEGIN;
                THROW 52000, N'KRS jest już w bazie', 1
            END

            IF @NIP IS NOT NULL AND @ClientType LIKE 'C' AND EXISTS( SELECT * FROM Companies WHERE NIP LIKE @NIP)
            BEGIN;
                THROW 52000, N'NIP jest już w bazie', 1
            END

            IF @REGON IS NOT NULL AND @ClientType LIKE 'C' AND EXISTS( SELECT * FROM Companies WHERE Regon LIKE @REGON)
            BEGIN;
                THROW 52000, N'REGON jest już w bazie', 1
            END

            IF (@ClientType = 'C')
            BEGIN
                IF(@NIP IS NULL)
                BEGIN
                    THROW 52000, N'Nip musi być określony dla klienta firmowego!', 1
                END

                IF(@CompanyName IS NULL)
                BEGIN
                    THROW 52000, N'CompanyName musi być określony dla klienta firmowego!', 1
                END
            END

            IF (@ClientType = 'I')
            BEGIN
                IF(@LastName IS NULL)
                BEGIN
                    THROW 52000, N'Nazwisko musi być określony dla klienta indywidualnego!', 1
                END

                IF(@FirstName IS NULL)
                BEGIN
                    THROW 52000, N'Imie musi być określony dla klienta indywidualnego!',1
                END
            END

            IF @Street IS NOT NULL AND @PostalCode IS NULL AND @LocalNr IS NULL AND @CityName IS NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @Street! Musisz podać jeszcze @CityName, @LocalNr, @PostalCode!', 1
            END

            IF @Street IS NULL AND @PostalCode IS NOT NULL AND @LocalNr IS NULL AND @CityName IS NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @PostalCode! Musisz podać jeszcze @Street, @LocalNr, @CityName!', 1
            END

            IF @Street IS NULL AND @PostalCode IS NULL AND @LocalNr IS NOT NULL AND @CityName IS NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @LocalNr. Musisz podać jeszcze @Street, @CityName, @PostalCode!', 1
            END

            IF @Street IS NULL AND @PostalCode IS NULL AND @LocalNr IS NULL AND @CityName IS NOT NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @CityName. Musisz podać jeszcze @Street, @LocalNr, @PostalCode!', 1
            END

            IF @Street IS NOT NULL AND @PostalCode IS NOT NULL AND @LocalNr IS NOT NULL AND @CityName IS NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @Street, @PostalCode, @LocalNr. Musisz podać jeszcze @CityName!', 1
            END

            IF @Street IS NOT NULL AND @PostalCode IS NOT NULL AND @LocalNr IS NULL AND @CityName IS NOT NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @Street, @PostalCode, @CityName. Musisz podać jeszcze @LocalNr!', 1
            END

            IF @Street IS NOT NULL AND @PostalCode IS NULL AND @LocalNr IS NOT NULL AND @CityName IS NOT NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @Street, @LocalNr, @CityName. Musisz podać jeszcze @PostalCode!', 1
            END

            IF @Street IS NULL AND @PostalCode IS NOT NULL AND @LocalNr IS NOT NULL AND @CityName IS NOT NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @PostalCode, @LocalNr, @CityName. Musisz podać jeszcze @Street!', 1
            END

            IF @Street IS NULL AND @PostalCode IS NULL AND @LocalNr IS NOT NULL AND @CityName IS NOT NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @LocalNr, @CityName. Musisz podać jeszcze @Street, @PostalCode!', 1
            END

            IF @Street IS NULL AND @PostalCode IS NOT NULL AND @LocalNr IS NULL AND @CityName IS NOT NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @PostalCode, @CityName. Musisz podać jeszcze @Street, @LocalNr!', 1
            END

            IF @Street IS NULL AND @PostalCode IS NOT NULL AND @LocalNr IS NOT NULL AND @CityName IS NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @PostalCode, @LocalNr. Musisz podać jeszcze @Street, @CityName!', 1
            END

            IF @Street IS NOT NULL AND @PostalCode IS NULL AND @LocalNr IS NULL AND @CityName IS NOT NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @Street, @CityName. Musisz podać jeszcze @PostalCode, @LocalNr!', 1
            END

            IF @Street IS NOT NULL AND @PostalCode IS NULL AND @LocalNr IS NOT NULL AND @CityName IS NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @Street, @LocalNr. Musisz podać jeszcze @PostalCode, @CityName!', 1
            END

            IF @Street IS NOT NULL AND @PostalCode IS NOT NULL AND @LocalNr IS NULL AND @CityName IS NULL
            BEGIN
                THROW 52000, N'Nie można podać tylko @Street, @PostalCode. Musisz podać jeszcze @LocalNr, @CityName!', 1
            END


            DECLARE @AddressID_ int;
            IF @Street IS NOT NULL AND @PostalCode IS NOT NULL AND @LocalNr IS NOT NULL AND @CityName IS NOT NULL
                BEGIN
                    IF NOT EXISTS( SELECT * FROM Address WHERE street LIKE @Street AND PostalCode LIKE @PostalCode AND LocalNr LIKE @LocalNr)
                        BEGIN
                            EXEC addAddress @Street,@LocalNr,@PostalCode,@CityName
                        END
                    SELECT @AddressID_ = AddressID FROM Address
                END
            ELSE
                BEGIN
                    IF @AddressID IS NOT NULL
                        BEGIN
                           SET @AddressID_ = @AddressID
                        END
                    ELSE
                        BEGIN
                            THROW 52000, 'Nie można, żeby wszystkie parametry nie zostały podane tj. @AddressID, @Street, @PostalCode, @LocalNr, @CityName. Musisz podać @AddressID lub @Street, @PostalCode, @LocalNr, @CityName!', 1
                        END
                END


            INSERT INTO Clients(AddressID, Phone, Email)
            VALUES(@AddressID_, @Phone, @Email)

            DECLARE @ClientID int;
            SELECT @ClientID = ClientID FROM Clients
            WHERE @AddressID_ = AddressID
                AND Clients.Phone LIKE @Phone
                AND Clients.Email LIKE @Email

            IF (@ClientType = 'C')
            BEGIN
                INSERT INTO Companies(ClientID, CompanyName, NIP, KRS, Regon)
                VALUES(@ClientID, @CompanyName, @NIP, @KRS, @REGON)
            END

            IF (@ClientType = 'I')
            BEGIN
                EXEC addPerson @FirstName,@LastName

                DECLARE @PersonID int
                SELECT @PersonID = PersonID FROM Person

                INSERT INTO IndividualClient(ClientID, PersonID)
                VALUES(@ClientID, @PersonID)
            END
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Bład dodania klienta: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
--addclient 
--addProduct to Menu 
CREATE PROCEDURE addProductToMenu   @Name nvarchar(150),
                                    @MenuID int,
                                    @Price money
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(
                SELECT * FROM Products WHERE Name like @Name
                )
            BEGIN;
                THROW 52000, N'Nie ma takiego produktu', 1
            END
            IF EXISTS(SELECT * FROM Products WHERE Name LIKE @Name AND IsAvailable = 0)
                BEGIN
                    THROW 52000, N'Ten produkt jest aktualnie niedostępny!', 1
                END

            IF NOT EXISTS(
                SELECT * FROM Menu WHERE MenuID = @MenuID
                )
            BEGIN;
                THROW 52000, N'Nie ma takiego menu. Dodaj napierw menu aby dodać produkt!', 1
            END


            DECLARE @ProductID int
            SELECT @ProductID = ProductID from Products WHERE Name like @Name

            IF EXISTS(SELECT * FROM MenuDetails WHERE ProductID = @ProductID AND MenuID = @MenuID)
                 BEGIN
                    THROW 52000, N'Produkt już jest w menu!', 1
                 END

            INSERT INTO MenuDetails(MenuID, ProductID, Price)
            VALUES (@MenuID, @ProductID, @Price)

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania potrawy do menu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
go
--add Product to Menu 
--remove Product From Menu 
CREATE PROCEDURE removeProductFromMenu  @Name nvarchar(150),
                                        @MenuID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(
                SELECT * FROM Products WHERE Name like @Name
                )
            BEGIN;
                THROW 52000, N'Nie ma takiej potrawy', 1
            END

            IF NOT EXISTS(
                SELECT * FROM Menu WHERE MenuID = @MenuID
                )
            BEGIN;
                THROW 52000, N'Nie ma takiego menu', 1
            END

            IF NOT EXISTS(
                SELECT * FROM MenuDetails MD
                    INNER JOIN Products P ON P.ProductID = MD.ProductID
                WHERE MenuID = @MenuID AND Name like @Name
                )
            BEGIN;
                THROW 52000, N'Nie ma takiego produktu w menu', 1
            END

            DECLARE @ProductID int
            SELECT @ProductID = ProductID from Products WHERE Name like @Name

            DELETE FROM MenuDetails  WHERE MenuID = @MenuID and ProductID = @ProductID

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd usunięcia potrawy z menu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
--remove Product From Menu 
--add menu 
CREATE PROCEDURE addMenu  @StartDate datetime,
                          @EndDate datetime = NULL,
                          @Description varchar(max) = NULL
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF EXISTS(SELECT * FROM Menu WHERE CAST(startDate AS date) = CAST(@StartDate AS date))
                BEGIN
                    THROW 52000, N'Menu zaczynające się w ten dzień już istnieje!', 1
                END
            IF EXISTS(SELECT * FROM Menu WHERE CAST(endDate AS date) = CAST(@EndDate AS date))
                BEGIN
                    THROW 52000, N'Menu kończące się w ten dzień już istnieje!', 1
                END
            IF EXISTS(SELECT * FROM Menu WHERE CAST(startDate AS date) = CAST(@StartDate AS date) AND CAST(endDate AS date) = CAST(@EndDate AS date))
                BEGIN
                    THROW 52000, N'Menu już istnieje!', 1
                END
            DECLARE @MenuID int
            SELECT @MenuID = ISNULL(MAX(MenuID), 0) + 1 FROM Menu

            IF @Description IS NOT NULL
                INSERT INTO Menu(MenuID,startDate, endDate, Description)
                VALUES(@MenuID, @StartDate, @EndDate, @Description)
            ELSE
                INSERT INTO Menu(MenuID,startDate, endDate)
                VALUES(@MenuID, @StartDate, @EndDate)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania menu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
--add menu
-- UPDATE MENU DESCRIPTION 
CREATE PROCEDURE UpdateMenuDescription(@MenuID int, @Description varchar)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(
                    SELECT * FROM Menu WHERE MenuID = @MenuID
                )
                BEGIN;
                    THROW 52000, 'Nie ma takiego menu!',1
                END
            UPDATE Menu SET Description = @Description WHERE MenuID = @MenuID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania/zmienienia opisu menu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- UPDATE MENU DESCRIPTION
--create invoice
CREATE PROCEDURE [create invoice] @OrderID int,
  @InvoiceDate datetime,
  @PaymentMethodName varchar(50),
  @PaymentStatusName varchar(50),
  @InvoiceID int output
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(
                SELECT OrderID FROM Orders
                WHERE OrderID = @OrderID
            )
            BEGIN;
                THROW 52000, N'Nie ma takiego zamówienia', 1
            END

            IF NOT EXISTS(
                    SELECT PaymentName FROM PaymentMethods
                    WHERE PaymentName LIKE @PaymentMethodName
            )
            BEGIN;
                THROW 52000, N'Nie ma takiej metody płatności', 1
            END

            IF NOT EXISTS(
                    SELECT PaymentStatusName FROM PaymentStatus
                    WHERE PaymentStatusName LIKE @PaymentStatusName
            )
            BEGIN;
                THROW 52000, N'Nie ma takiego statusu płatności', 1
            END

            DECLARE @invoiceNum nvarchar(50) = concat('FV/', cast(@OrderID AS nvarchar(50)), '/', cast(year((SELECT OrderCompletionDate FROM Orders
                                                                                                                WHERE OrderID = @OrderID)) AS nvarchar(4)))
            DECLARE @ClientID int = (SELECT ClientID FROM Orders
                                        WHERE OrderID = @OrderID)
            DECLARE @InvoiceIDs TABLE (ID int)
            DECLARE @PaymentMethodID int
            DECLARE @PaymentStatusID int

            SELECT @PaymentMethodID = PaymentMethodID FROM PaymentMethods WHERE PaymentName LIKE @PaymentMethodName
            SELECT @PaymentStatusID = PaymentStatusID FROM PaymentStatus WHERE PaymentStatusName LIKE @PaymentStatusName

            INSERT INTO
              Invoice(InvoiceNumber, InvoiceDate, DueDate, ClientID, PaymentStatusID, PaymentMethodID) OUTPUT inserted.InvoiceID INTO @InvoiceIDs
                VALUES (@invoiceNum, @InvoiceDate, dateadd(DAY, 12, GETDATE()), @ClientID, @PaymentStatusID, @PaymentMethodID)
            SELECT @InvoiceID = ID FROM @InvoiceIDs RETURN @InvoiceID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania faktury: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
go
--create invoice
-- add Payment Status
CREATE PROCEDURE [add Payment Status] @PaymentStatusName varchar(50)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            INSERT INTO PaymentStatus(PaymentStatusName) values (@PaymentStatusName)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania metody płatności do zamówienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH 
    END
GO
-- add Payment Status
-- add Payment Method
CREATE PROCEDURE [add Payment Method] @PaymentMethodName varchar(50)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            INSERT INTO PaymentMethods(PaymentName) values (@PaymentMethodName)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania metody płatności do zamówienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- add Payment Method
-- change Payment method for order
CREATE PROCEDURE [change payment method for order] @PaymentMethodName varchar(50), @OrderID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT OrderID FROM Orders WHERE OrderID = @OrderID)
                BEGIN;
                    THROW 52000, 'Brak takiego zamowienia', 1
                END
            IF NOT EXISTS(SELECT PaymentMethodID FROM PaymentMethods WHERE PaymentName LIKE @PaymentMethodName)
                BEGIN;
                    THROW 52000, 'Brak takiej metody platnosci', 1
                END

            DECLARE @PaymentMethodID int;

            SELECT @PaymentMethodID =  PaymentMethodID FROM PaymentMethods WHERE PaymentName LIKE @PaymentMethodName

            UPDATE Orders SET PaymentMethodID = @PaymentMethodID WHERE OrderID = @OrderID
        END TRY
        BEGIN CATCH
                DECLARE @msg nvarchar(2048) = N'Błąd zmiany metody: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
        END CATCH
    END
GO
-- change Payment method for order
-- change Payment method for invoice
CREATE PROCEDURE [change payment method for invoice] @PaymentMethodName varchar(50), @InvoiceID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF not EXISTS(SELECT InvoiceID FROM Invoice WHERE InvoiceID = @InvoiceID)
                BEGIN;
                    THROW 52000, 'Brak takiego zamowienia', 1
                END
            IF not EXISTS(SELECT PaymentMethodID FROM PaymentMethods WHERE PaymentName LIKE @PaymentMethodName)
                BEGIN;
                    THROW 52000, 'Brak takiej metody platnosci', 1
                END

            DECLARE @PaymentMethodID int;

            SELECT @PaymentMethodID =  PaymentMethodID FROM PaymentMethods WHERE PaymentName LIKE @PaymentMethodName

            UPDATE Invoice SET PaymentMethodID = @PaymentMethodID WHERE InvoiceID = @InvoiceID
        END TRY
        BEGIN CATCH
                DECLARE @msg nvarchar(2048) = N'Błąd zmiany metody: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
        END CATCH
    END
GO
-- change Payment method for invoice
-- change Payment status for invoice
CREATE PROCEDURE [change payment status for invoice] @PaymentStatusName varchar(50), @InvoiceID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT InvoiceID FROM Invoice WHERE InvoiceID = @InvoiceID)
                BEGIN;
                    THROW 52000, 'Brak takiego zamowienia', 1
                END
            IF NOT EXISTS(select PaymentStatusID FROM PaymentStatus WHERE PaymentStatus.PaymentStatusName LIKE @PaymentStatusName)
                BEGIN;
                    THROW 52000, 'Brak takiego statusu platnosci', 1
                END
            DECLARE @PaymentStatusID int;

            SELECT @PaymentStatusID = PaymentStatusID FROM PaymentStatus WHERE PaymentStatus.PaymentStatusName LIKE @PaymentStatusName

            UPDATE Invoice SET PaymentStatusID = @PaymentStatusID WHERE  InvoiceID = @InvoiceID
        END TRY
        BEGIN CATCH
                DECLARE @msg nvarchar(2048) = N'Błąd zmiany statusu: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
        END CATCH
    END
GO
-- change Payment status for invoice

-- change Payment status for order
CREATE PROCEDURE [change payment status for order] @PaymentStatusName varchar(50), @OrderID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT OrderID FROM Orders WHERE OrderID = @OrderID)
                BEGIN;
                    THROW 52000, 'Brak takiego zamowienia', 1
                END
            IF NOT EXISTS(SELECT PaymentStatusID FROM PaymentStatus WHERE PaymentStatus.PaymentStatusName LIKE @PaymentStatusName)
                BEGIN;
                    THROW 52000, 'Brak takiego statusu platnosci', 1
                END

            DECLARE @PaymentStatusID int;

            SELECT @PaymentStatusID = PaymentStatusID FROM PaymentStatus WHERE PaymentStatus.PaymentStatusName LIKE @PaymentStatusName

            UPDATE Orders SET PaymentStatusID = @PaymentStatusID WHERE OrderID = @OrderID
        END TRY
        BEGIN CATCH
                DECLARE @msg nvarchar(2048) = N'Błąd zmiany statusu: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
        END CATCH
    END
GO
-- change Payment status for order
-- order Insert Instant Pay
CREATE PROCEDURE AddOrderInstantPay @ClientID int,
                                    @OrderCompletionDate datetime = null,
                                    @PaymentStatusName_ varchar(50),
                                    @PaymentMethodName_ varchar(50),
                                    @OrderStatus varchar(15),
                                    @StaffID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF @OrderCompletionDate IS NOT NULL AND  @OrderCompletionDate <= GETDATE()
            BEGIN
                THROW 52000, N'Data ukończenia zamówienia musi być większa od aktualnej!', 1
            END
        IF NOT EXISTS(SELECT PaymentStatusID FROM PaymentStatus WHERE PaymentStatusName LIKE @PaymentStatusName_)
            BEGIN;
                THROW 52000, 'Nie ma takiego statusu!', 1
            END
        IF NOT EXISTS(select PaymentMethods.PaymentName FROM PaymentMethods WHERE PaymentMethods.PaymentName LIKE @PaymentMethodName_)
            BEGIN;
                THROW 52000, 'Nie ma takiej metody!', 1
            END
        IF NOT EXISTS(SELECT StaffID FROM Staff WHERE StaffID = @StaffID)
            BEGIN;
                THROW 52000, 'Nie ma takiego pracownika!', 1
            END

        DECLARE @OrderIDTable TABLE
                (
                    Id int
                )

        DECLARE @OrderID int
        DECLARE @PaymentMethodID int
        DECLARE @PaymentStatusID int
        DECLARE @InvoiceID int

        SELECT @PaymentStatusID =  PaymentStatusID FROM PaymentStatus WHERE PaymentStatusName LIKE @PaymentStatusName_
        SELECT @PaymentMethodID =  PaymentMethods.PaymentMethodID FROM PaymentMethods WHERE PaymentMethods.PaymentName LIKE @PaymentMethodName_

        INSERT INTO Orders (ClientID, PaymentStatusID, PaymentMethodID, staffID, OrderSum, OrderCompletionDate, OrderStatus, OrderDate)
        OUTPUT inserted.OrderID INTO @OrderIDTable
        VALUES (@ClientID, @PaymentStatusID, @PaymentMethodID, @StaffID , 0.0, @OrderCompletionDate, @OrderStatus, GETDATE());

        SELECT @OrderID = Id FROM @OrderIDTable
        EXEC dbo.[create invoice] @OrderID = @OrderID, @InvoiceDate = @OrderCompletionDate, @PaymentMethodName = @PaymentMethodName_, @PaymentStatusName = @PaymentStatusName_, @InvoiceID = @InvoiceID OUTPUT
        UPDATE [Orders] SET InvoiceID= @InvoiceID WHERE OrderID = @OrderID
        RETURN @OrderID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048) = N'Błąd dodania zamowienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg,1
    END CATCH
END
go




-- order Insert Instant Pay
-- order Insert Month Pay
CREATE PROCEDURE AddOrderMonthPay   @ClientID int,
                                    @OrderCompletionDate datetime,
                                    @PaymentStatusName_ varchar(50),
                                    @PaymentMethodName_ varchar(50),
                                    @OrderStatus varchar(15),
                                    @StaffID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF @OrderCompletionDate IS NOT NULL AND  @OrderCompletionDate <= GETDATE()
            BEGIN
                THROW 52000, N'Data ukończenia zamówienia musi być większa od aktualnej!', 1
            END
        IF NOT EXISTS(SELECT PaymentStatusID FROM PaymentStatus WHERE PaymentStatusName LIKE @PaymentStatusName_)
            BEGIN;
                THROW 52000, 'Nie ma takiego statusu!', 1
            END
        IF not EXISTS(SELECT PaymentMethods.PaymentName FROM PaymentMethods WHERE PaymentMethods.PaymentName LIKE @PaymentMethodName_)
            BEGIN;
                THROW 52000, 'Nie ma takiej metody!', 1
            END
        IF NOT EXISTS(SELECT StaffID FROM Staff WHERE StaffID = @StaffID)
            BEGIN;
                THROW 52000, 'Nie ma takiego pracownika!', 1
            END

        Declare @OrderIDTable table
                (
                    Id int
                )
        Declare @OrderID int
        DECLARE @PaymentMethodID int
        DECLARE @PaymentStatusID int
        DECLARE @startOfMonth datetime = cast(DATEADD(month, DATEDIFF(month, 0, @OrderCompletionDate) + 1, 0) AS date)
        DECLARE @InvoiceID int

        SELECT @PaymentStatusID =  PaymentStatusID FROM PaymentStatus WHERE PaymentStatusName LIKE @PaymentStatusName_
        SELECT @PaymentMethodID =  PaymentMethods.PaymentMethodID FROM PaymentMethods WHERE PaymentMethods.PaymentName LIKE @PaymentMethodName_

        INSERT INTO Orders (ClientID, PaymentStatusID, PaymentMethodID, staffID, OrderSum, OrderCompletionDate, OrderStatus, OrderDate)
        OUTPUT inserted.OrderID INTO @OrderIDTable
        VALUES (@ClientID, @PaymentStatusID, @PaymentMethodID, @StaffID , 0.0, @OrderCompletionDate, @OrderStatus, GETDATE());

        SELECT @OrderID = Id FROM @OrderIDTable


        SELECT @InvoiceID = InvoiceID FROM Invoice
        WHERE ClientID = @ClientID
            AND month(InvoiceDate) = month(@startOfMonth)
            AND year(InvoiceDate) = year(@startOfMonth)

        IF @InvoiceID IS NULL
            BEGIN;
                EXEC dbo.[create invoice] @OrderID = @OrderID, @InvoiceDate = @startOfMonth, @PaymentMethodName = @PaymentMethodName_, @PaymentStatusName = @PaymentStatusName_, @InvoiceID = @InvoiceID OUTPUT
            END

        UPDATE [Orders] SET InvoiceID= @InvoiceID WHERE OrderID = @OrderID
        RETURN @OrderID
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048) = N'Błąd dodania zamowienia: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END;
go
-- order Insert Month Pay
-- add Staff Member
CREATE PROCEDURE addStaffMember @LastName nvarchar(50), @FirstName nvarchar(70), @Position varchar(50), @Email varchar(100), @Phone varchar(14), @AddressID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF EXISTS(SELECT * FROM Staff WHERE Email LIKE @Email)
            BEGIN;
                THROW 52000, 'Pracownik o takim emailu już istnieje!', 1
            END

            IF NOT EXISTS(SELECT * FROM Address WHERE AddressID = @AddressID)
            BEGIN;
                THROW 52000, 'Nie ma takiego adresu!', 1
            END
            IF EXISTS(SELECT * FROM Staff WHERE LastName = @LastName AND FirstName = @FirstName AND Position = @Position AND Email = @Email AND Phone = @Phone AND AddressID = @AddressID)
            BEGIN;
                THROW 52000, 'Taki pracownik już istnieje!', 1
            END


            INSERT INTO Staff (LastName, FirstName, Position, Email, Phone, AddressID)
            VALUES (@LastName, @FirstName, @Position, @Email, @Phone, @AddressID);
        END TRY
        BEGIN CATCH
            DECLARE @msg varchar(2048) = N'Błąd dodania nowego pracownika: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- add Staff Member
-- add Product
CREATE PROCEDURE addProduct @CategoryID int, @Name nvarchar(50), @Description nvarchar(150) = NULL, @IsAvailable bit = NULL
AS
    BEGIN
       SET NOCOUNT ON
       BEGIN TRY
           IF EXISTS(SELECT * FROM Products WHERE Name LIKE @Name)
           BEGIN;
                THROW 52000, N'Taki produkt już istnieje!', 1
            END
            IF @Description IS NULL AND @IsAvailable IS NOT NULL
            BEGIN
                INSERT INTO Products(CategoryID, Name, IsAvailable)
                VALUES (@CategoryID, @Name, @IsAvailable)
            END
            ELSE IF @Description IS NOT NULL AND @IsAvailable IS NULL
            BEGIN
                INSERT INTO Products(CategoryID, Name, Description)
                VALUES (@CategoryID, @Name, @Description)
            END
            ELSE
            BEGIN
                INSERT INTO Products(CategoryID, Name, Description, IsAvailable)
                VALUES (@CategoryID, @Name, @Description, @IsAvailable)
            END
       END TRY
       BEGIN CATCH
           DECLARE @msg varchar(2048) = N'Błąd dodania nowego produktu: ' + ERROR_MESSAGE()
           THROW 52000, @msg, 1
       END CATCH
    END
GO
-- add Product
-- add city 


--add city

--remove city
CREATE PROCEDURE removeCity @CityID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Cities WHERE CityID = @CityID)
            BEGIN
                THROW 52000, 'Nie ma takiego miasta!', 1
            END
            DELETE FROM Cities WHERE CityID = @CityID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd usunięcia miasta: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
--remove city

CREATE PROCEDURE removeCategory @CategoryID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Category WHERE CategoryID = @CategoryID)
            BEGIN
                THROW 52000, 'Nie ma takiej kategorii!', 1
            END

            DELETE FROM Category WHERE CategoryID = @CategoryID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd usunięcia kategorii: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO

CREATE PROCEDURE removeProduct @ProductID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Products WHERE ProductID = @ProductID)
            BEGIN;
                THROW 52000, 'Nie ma takiego produktu!', 1
            END
            DELETE FROM Products WHERE ProductID = @ProductID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd usunięcia produktu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO

CREATE PROCEDURE changeOrderStatus @OrderID int, @OrderStatus varchar(15)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID = @OrderID)
            BEGIN;
                THROW 52000, N'Nie ma takiego zamówienia!', 1
            END
            IF LOWER(@OrderStatus) NOT IN('pending', 'accepted', 'completed', 'denied', 'picked', 'cancelled')
                BEGIN
                    THROW 52000, N'Nie ma takiego statusu zamówienia! ', 1
                END
            IF LOWER(@OrderStatus) LIKE 'picked' AND NOT EXISTS(SELECT  * FROM Orders INNER JOIN OrdersTakeaways OT ON Orders.TakeawayID = OT.TakeawaysID WHERE OrderID = @OrderID)
                BEGIN
                    THROW 52000, N'To zamówienie nie jest na wynos!', 1
                END
            UPDATE Orders SET OrderStatus = @OrderStatus WHERE OrderID = @OrderID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd odrzucenia zamówienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO

-- changeEmployeeResponsibleForOrder
CREATE PROCEDURE changeEmployeeResponsibleForOrder @OrderID int, @StaffID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Orders WHERE ReservationID = @OrderID)
                BEGIN;
                    THROW 52000, N'Nie ma takiego zamówienia!', 1
                END
            IF NOT EXISTS(SELECT * FROM Staff WHERE StaffID = @StaffID)
                BEGIN;
                    THROW 52000, N'Nie ma takiego pracownika!', 1
                END
            UPDATE Orders SET StaffID = @StaffID WHERE ReservationID = @OrderID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd w zmianie pracownika: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO;
-- changeEmployeeResponsibleForOrder

-- changeEmployeeResponsibleForReservation
CREATE PROCEDURE changeEmployeeResponsibleForReservation @ReservationID int, @StaffID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Reservation WHERE ReservationID = @ReservationID)
                BEGIN;
                    THROW 52000, N'Nie ma takiej rezerwacji!', 1
                END
            IF NOT EXISTS(SELECT * FROM Staff WHERE StaffID = @StaffID)
                BEGIN;
                    THROW 52000, N'Nie ma takiego pracownika!', 1
                END
            UPDATE Reservation SET StaffID = @StaffID WHERE ReservationID = @ReservationID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd w zmianie pracownika: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO;
-- changeEmployeeResponsibleForReservation

-- show best discount 
CREATE PROCEDURE showBestDiscount @ClientID int, @DiscountType varchar
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Clients WHERE ClientID = @ClientID)
            BEGIN;
                THROW 52000, N'Nie ma takiego klienta!', 1
            END
            IF LOWER(@DiscountType) LIKE 'temporary'
                BEGIN;
                    SELECT max(DiscountValue) AS 'Discount Value' FROM IndividualClient I
                        INNER JOIN Discounts D ON I.ClientID = D.ClientID
                        INNER JOIN DiscountsVar DV ON DV.VarID = D.VarID
                    WHERE DiscountType = 'Temporary'
                        AND I.ClientID = @ClientID
                        AND AppliedDate <= getdate() AND GETDATE() <= dateadd(DAY, ValidityPeriod, AppliedDate)
                END
            ELSE IF LOWER(@DiscountType) LIKE 'permanent'
                BEGIN;
                    SELECT max(DiscountValue) AS 'Discount Value' FROM IndividualClient I
                        INNER JOIN Discounts D ON I.ClientID = D.ClientID
                        INNER JOIN DiscountsVar DV ON DV.VarID = D.VarID
                    WHERE DiscountType = 'Permanent'
                        AND I.ClientID = @ClientID
                        AND AppliedDate <= getdate() AND GETDATE() <= dateadd(DAY, ValidityPeriod, AppliedDate)
                END
            ELSE
                BEGIN
                   THROW 52000, N'Nie ma takiego typu zniżki', 1
                END
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd wyświetlenia zniżki: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- show best discount 

-- change reservation status
CREATE PROCEDURE changeReservationStatus @ReservationID int, @Status varchar(15)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Reservation WHERE ReservationID = @ReservationID)
                BEGIN;
                    THROW 52000, N'Nie ma takiej rezerwacji!', 1
                END
            UPDATE Reservation SET Status = @Status
            WHERE Reservation.ReservationID = @ReservationID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd edytowania rezerwacji: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- change reservation status

-- add product to order
CREATE PROCEDURE AddProductToOrder @OrderID int,
                                   @Quantity int,
                                   @ProductName nvarchar(50)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
        IF NOT EXISTS(SELECT * FROM Products WHERE Name = @ProductName)
          BEGIN;
                THROW 52000, N'Nie ma takiej potrawy', 1
          END
        IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID = @OrderID)
            BEGIN;
                THROW 52000, 'Nie ma takiego zamowienia', 1
            END
        IF NOT EXISTS(SELECT * FROM CurrentMenu CM WHERE CM.Name like @ProductName)
        BEGIN;
            THROW 52000, N'Nie mozna zamowic tego produktu, gdyz nie ma go obecnie w menu', 1
        END

        DECLARE @OrderDate DATE

        SELECT @OrderDate = OrderDate FROM Orders WHERE OrderID = @OrderID DECLARE @CategoryName nvarchar(50)
        SELECT @CategoryName = CategoryName FROM Products
            INNER JOIN Category ON Category.CategoryID = Products.CategoryID
        WHERE
        Products.Name = @ProductName

        DECLARE @ProductID INT
        SELECT @ProductID = ProductID FROM Products WHERE Name = @ProductName

        IF EXISTS(SELECT * FROM OrderDetails WHERE OrderID = @OrderID AND ProductID = @ProductID)
        BEGIN;
            THROW 52000, N'Produkt jest już w zamówieniu!', 1
        END

        DECLARE @BasePrice money
        SELECT @BasePrice = Price from CurrentMenu CM where CM.Name LIKE @ProductName

        DECLARE @CurrentValue money
        DECLARE @ClientID int
        DECLARE @DiscMulti decimal(3, 2);

        SELECT @CurrentValue = OrderSum FROM [Orders] WHERE OrderID = @OrderId
        SELECT @ClientID = ClientID, @OrderDate = OrderDate FROM Orders WHERE OrderID = @OrderId
        SELECT @DiscMulti = dbo.calculateDiscountForClient(@ClientID)

        INSERT INTO OrderDetails(OrderID, Quantity, ProductID) VALUES (@OrderID, @Quantity, @ProductID)

        IF @DiscMulti IS NOT NULL
            BEGIN
                UPDATE Orders SET OrderSum = @CurrentValue + (@BasePrice * @Quantity * @DiscMulti) WHERE OrderID = @OrderID
            END
        ELSE
            BEGIN
                UPDATE Orders SET OrderSum = @CurrentValue + (@BasePrice * @Quantity * 1) WHERE OrderID = @OrderID
            END
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania produktu do zamowienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
go


-- add product to order

-- employee assigned to the order
CREATE PROCEDURE EmployeeAssignedToTheOrder @OrderID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
        IF NOT EXISTS(SELECT * FROM Orders
                        WHERE OrderID = @OrderID
        )
        BEGIN;
            THROW 52000, 'Nie ma takiego zamowienia', 1
        END
        SELECT S.FirstName, S.LastName, S.Position, S.Email, S.Phone, O.OrderID, O.OrderStatus, O.OrderDate FROM Staff AS S
            INNER JOIN Orders O ON O.StaffID = S.StaffID
        WHERE
            O.OrderID = @OrderID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd wypisywania pracownikow:' + ERROR_MESSAGE();
            THROW 52000,@msg,1
        END CATCH
    END
GO
-- employee assigned to the order

-- get dishes for day
CREATE PROCEDURE dbo.getDishesForDay @data Date
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            SELECT O.OrderID, cast(OrderCompletionDate AS Date) AS 'OrderCompletionDate', P.Name, sum(OD.Quantity) AS 'Quantity' FROM Orders O
                 INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                 INNER JOIN Products P ON OD.ProductID = P.ProductID
            WHERE cast(OrderCompletionDate AS Date) = @data
            GROUP BY O.OrderID, O.OrderCompletionDate, P.Name
        END TRY
        BEGIN CATCH
            DECLARE @msg varchar(2048) = N'Bład wyświetlenia danych: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- get dishes for day

-- Client Statistics
CREATE PROCEDURE Client_Statistics @ClientID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT ClientID FROM Clients WHERE ClientID = @ClientID)
                BEGIN;
                    throw 52000, 'Nie ma takiego klienta!', 1
                END

            DECLARE @PaymentStatusID int

            SELECT @PaymentStatusID = PaymentStatusID FROM PaymentStatus WHERE PaymentStatusName LIKE 'Paid'

            SELECT O.OrderID, O.OrderDate, O.OrderSum, O.OrderSum - O2.no_disc AS [discount value], 1 - (O2.no_disc/O.OrderSum) AS [discount multiplier] FROM Orders O
                INNER JOIN (SELECT O.OrderID, sum(Quantity) AS no_disc
                            FROM Orders O
                                INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
                                INNER JOIN Products P ON OD.ProductID = P.ProductID
                                INNER JOIN MenuDetails MD ON P.ProductID = MD.ProductID
                                INNER JOIN Menu M ON MD.MenuID = M.MenuID
                            WHERE M.startDate <= GETDATE() AND (M.endDate IS NULL OR M.endDate >= getdate())
                            GROUP BY O.OrderID) O2 ON O2.OrderID = O.OrderID
                WHERE ClientID = @ClientID AND PaymentStatusID = @PaymentStatusID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd wyswietlenia statystyk o kliencie: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- Client Statistics

-- add payment status 

CREATE PROCEDURE AddPaymentStatus @PaymentStatusName varchar(50)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF EXISTS(SELECT * FROM PaymentStatus WHERE PaymentStatusName = @PaymentStatusName)
                BEGIN;
                    THROW 52000, 'Istnieje już taki status płatności', 1
                END
            INSERT INTO PaymentStatus (PaymentStatusName) VALUES (@PaymentStatusName)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd dodania statusu płatności: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- add payment status 

-- add payment method 
CREATE PROCEDURE AddPaymentMethod @PaymentMethodName varchar(50)
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF EXISTS(SELECT * FROM PaymentMethods WHERE PaymentName = @PaymentMethodName)
                BEGIN;
                    THROW 52000, 'Istnieje już taka metoda płatności', 1
                END
            INSERT INTO PaymentMethods (PaymentName) VALUES (@PaymentMethodName)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd dodania metody płatności: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- add payment method 

-- add takeaway 
CREATE PROCEDURE AddTakeaway @PrefDate datetime
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            INSERT INTO OrdersTakeaways (PrefDate) VALUES (@PrefDate)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd dodania zamowienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- add takeaway

-- add takeaway to order
CREATE PROCEDURE AddTakeawayToOrder @OrderID int, @PrefDate datetime
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID = @OrderID)
                BEGIN;
                    THROW 52000, 'Nie ma takiego zamowienia', 1
                END

            IF @PrefDate < GETDATE()
                BEGIN
                    THROW 52000, N'Data nie może być wcześniejsza niż dzisiejsza!', 1
                END
            EXEC AddTakeaway @PrefDate
            DECLARE @TakeawayID int;
            SELECT @TakeawayID = MAX(TakeawaysID) FROM OrdersTakeaways

            UPDATE Orders SET TakeawayID = @TakeawayID WHERE OrderID = @OrderID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd dodania zamowienia do zamowienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- add takeaway to order
-- add reservation to order 
CREATE PROCEDURE AddReservationToOrder @OrderID int, @ReservationID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID = @OrderID)
                BEGIN;
                    THROW 52000, 'Nie ma takiego zamowienia', 1
                END

            IF NOT EXISTS(SELECT * FROM Reservation WHERE ReservationID = @ReservationID)
                BEGIN;
                    THROW 52000, 'Nie ma takiego rezerwacji', 1
                END
            DECLARE @ReservationIDAssignmentToOrder int
            SET @ReservationIDAssignmentToOrder = (SELECT ReservationID FROM Orders WHERE OrderID = @OrderID)
            IF @ReservationIDAssignmentToOrder IS NOT NULL
                BEGIN
                    THROW 52000, N'To zamówienie ma już swoją rezerwację!', 1
                END

            UPDATE Orders SET ReservationID = @ReservationID WHERE OrderID = @OrderID
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd dodania rezerwacji do zamowienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
go


-- add reservation to order

-- add Reservation
CREATE PROCEDURE AddReservation @ClientID int, @OrderID int , @StartDate datetime, @EndDate datetime, @StaffID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF @StartDate >= @EndDate
                BEGIN
                    THROW 52000, 'Data końca musi być większa od startu!', 1
                END
            IF NOT EXISTS(SELECT * FROM Clients WHERE ClientID = @ClientID)
                BEGIN;
                        THROW 52000, N'Nie ma takiego klienta', 1
                END

            IF NOT EXISTS(SELECT * FROM Staff WHERE StaffID = @StaffID)
                BEGIN;
                        THROW 52000, N'Nie ma takiego pracownika', 1
                END

            DECLARE @ReservationIDAssignmentToOrder int
            SET @ReservationIDAssignmentToOrder = (SELECT ReservationID FROM Orders WHERE OrderID = @OrderID)
            IF @ReservationIDAssignmentToOrder IS NOT NULL
                BEGIN
                    THROW 52000, N'To zamówienie ma już swoją rezerwację!', 1
                END

            DECLARE @ReservationID int
            DECLARE @PersonID int

            SELECT @ReservationID = ISNULL(MAX(ReservationID), 0) + 1 FROM Reservation


            INSERT INTO Reservation(ReservationID, startDate, endDate, Status, StaffID)
            VALUES (@ReservationID,@StartDate, @EndDate, 'waiting', @StaffID)

            IF EXISTS(SELECT * FROM Companies WHERE ClientID = @ClientID)
                BEGIN;
                    INSERT INTO ReservationCompany(ReservationID, ClientID, PersonID)
                    VALUES (@ReservationID, @ClientID, null)
                END
            ELSE
                BEGIN;
                    SELECT @PersonID=PersonID from IndividualClient WHERE ClientID = @ClientID
                    INSERT INTO ReservationIndividual(ReservationID, ClientID, PersonID)
                    VALUES (@ReservationID, @ClientID, @PersonID)
                END
            EXEC AddReservationToOrder @OrderID, @ReservationID
        END TRY
        BEGIN CATCH
                DECLARE @msg nvarchar(2048) = 'Błąd dodania rezerwacji: ' + ERROR_MESSAGE();
                THROW 52000, @msg, 1
        END CATCH
    END
go

-- add Reservation

-- add Table to  Reservation
CREATE PROCEDURE addTableToReservation @ReservationID int, @TableID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM TABLES WHERE TableID = @TableID)
            BEGIN;
                THROW 52000, 'Nie ma takiego stolika! ', 1
            END

            IF NOT EXISTS(SELECT * FROM Orders WHERE ReservationID = @ReservationID)
            BEGIN;
                THROW 52000, 'Nie ma takiej rezerwacji! ', 1
            END

            INSERT INTO ReservationDetails(ReservationID, TableID)
            VALUES (@ReservationID, @TableID)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd dodania stolika do rezerwacji: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO
-- add Table to  Reservation

-- Add reservation var
CREATE PROCEDURE AddReservationVar @WK int, @WZ money, @startDate datetime, @endDate datetime = NULL
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF EXISTS(SELECT * FROM ReservationVar WHERE WZ = @WZ AND WK = @WK AND startDate = @startDate AND endDate = @endDate)
                BEGIN;
                    THROW 52000, 'Istnieje już taka zmienna dotycząca rezerwacji', 1
                END
            INSERT INTO ReservationVar (WZ, WK, startDate, endDate) VALUES (@WZ, @WK, @startDate, @endDate)

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = 'Błąd dodania zmiennej dotyczącej rezerwacji: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO

-- add discount var 
CREATE PROCEDURE AddDiscountVar @MinimalOrders int = NULL, @MinimalValue money, @ValidityPeriod int = NULL, @DiscountValue decimal(3,2), @StartDate datetime, @EndDate datetime = NULL
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF EXISTS(SELECT * FROM DiscountsVar WHERE ((MinimalOrders = @MinimalOrders AND ValidityPeriod = @ValidityPeriod) OR  MinimalAggregateValue = @MinimalValue)  AND DiscountValue = @DiscountValue AND startDate = @StartDate AND endDate = @EndDate)
                BEGIN;
                    THROW 52000, N'Istnieje już taka zmienna dotycząca rabatu!', 1
                END
            IF @MinimalOrders IS NULL AND @ValidityPeriod IS NULL
                BEGIN;
                    THROW 52000, N'Nie można dodać zmiennych bez warunków! Podaj @MinimalOrders dla zniżki permanentnej lub @ValidityPeriod dla zniżki tymczasowej', 1
                END

            IF @ValidityPeriod IS NOT NULL AND @MinimalOrders IS NULL
                BEGIN;
                    INSERT INTO DiscountsVar (DiscountType,MinimalOrders, MinimalAggregateValue, ValidityPeriod, DiscountValue, startDate, endDate) VALUES ('Temporary',@MinimalOrders, @MinimalValue, @ValidityPeriod, @DiscountValue, @StartDate, @EndDate)
                END

            IF @MinimalOrders IS NOT NULL AND @ValidityPeriod IS NULL
                BEGIN;
                    INSERT INTO DiscountsVar (DiscountType,MinimalOrders, MinimalAggregateValue, ValidityPeriod, DiscountValue, startDate, endDate) VALUES ('Permanent',@MinimalOrders, @MinimalValue, @ValidityPeriod, @DiscountValue, @StartDate, @EndDate)
                END

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania zmiennej dotyczącej rabatu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
go

-- add discount var
-- add discount
CREATE PROCEDURE addDiscount @ClientID int, @DiscountType char(9)
AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM IndividualClient WHERE ClientID = @ClientID)
                BEGIN
                    THROW 52000, N'Nie ma takiego klienta indywidualnego! ', 1
                END
            IF LOWER(@DiscountType) NOT IN('permanent', 'temporary')
                BEGIN
                    THROW 52000, N'Nie ma takiego typu zniżki! ', 1
                END

            DECLARE @VarID int
            SET @VarID = (SELECT VarID FROM DiscountsVar WHERE LOWER(DiscountType) LIKE LOWER(@DiscountType)  AND (startDate <= GETDATE() AND (endDate IS NULL OR endDate >= GETDATE())))
            
            IF EXISTS(SELECT * FROM Discounts WHERE ClientID = @ClientID AND CAST(AppliedDate AS date) = CAST(GETDATE() AS DATE) AND VarID = @VarID)
                BEGIN 
                    return 
                END
            
          
            IF @DiscountType LIKE 'Permanent'
                BEGIN
                    INSERT INTO Discounts(ClientID, VarID, AppliedDate, isUsed)
                    VALUES(@ClientID, @VarID, GETDATE(), NULL)
                END
            ELSE
                BEGIN
                    INSERT INTO Discounts(ClientID, VarID, AppliedDate)
                    VALUES(@ClientID, @VarID, GETDATE())
                END
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania zmiennej dotyczącej rabatu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
go

-- add discount

-- add Employee to Company 
CREATE PROCEDURE addEmployeeToCompany @CompanyID int, @PersonID int
AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Companies WHERE ClientID = @CompanyID)
            BEGIN;
                THROW 52000, N'Nie ma takiej firmy! ', 1
            END

            IF NOT EXISTS(SELECT * FROM Person WHERE PersonID = @PersonID)
            BEGIN;
                THROW 52000, N'Nie ma takiej osoby! ', 1
            END

            INSERT INTO Employees(PersonID, CompanyID)
            VALUES (@PersonID, @CompanyID)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodania pracownika do firmy: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
GO

