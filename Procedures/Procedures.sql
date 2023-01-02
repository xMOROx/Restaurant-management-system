-- Category add
CREATE PROCEDURE Project.dbo.addCategory @CategoryName nvarchar(50),
@Description nvarchar(150) AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF EXISTS(
    SELECT
      *
    FROM
      Category
    WHERE
      @CategoryName = CategoryName
  ) BEGIN;

THROW 52000,
N'Kategoria juz istnieje!',
1
END
INSERT INTO
  Project.dbo.Category (CategoryName, Description)
VALUES
  (@CategoryName, @Description)
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Blad dodania kategorii: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- Category add
  -- Modify table size 
  CREATE PROCEDURE ModifyTableSize @TableID int,
  @Size int AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      TABLES
    WHERE
      TableID = @TableID
  ) BEGIN;

THROW 52000,
N 'Nie ma takiego stolika.',
1
END IF @Size < 2 BEGIN;

THROW 52000,
N'Stolik musi mieć przynajmniej 2 miejsca.',
1
END IF @Size IS NOT NULL BEGIN
UPDATE
  TABLES
SET
  ChairAmount = @Size
WHERE
  TableID = @TableID
END
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Bład edytowania stolika: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- Modify table size
  -- Modify table status
  CREATE PROCEDURE ModifyTableStatus @TableID int,
  @Status bit AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      TABLES
    WHERE
      TableID = @TableID
  ) BEGIN;

THROW 52000,
N 'Nie ma takiego stolika.',
1
END DECLARE @TableStatus bit
SELECT
  @TableStatus = isActive
FROM
  TABLES
WHERE
  TableID = @TableID IF @TableStatus = @Status BEGIN;

THROW 52000,
N'Stolik ma już taki status!.',
1
END IF @Status IS NOT NULL BEGIN
UPDATE
  TABLES
SET
  isActive = @Status
WHERE
  TableID = @TableID
END
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Bład edytowania stolika: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- Modify table status
  -- Add table
  CREATE PROCEDURE addTable @Size int,
  @Status bit AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF @Size < 2 BEGIN;

THROW 52000,
N'Stolik musi mieć przynajmniej 2 miejsca.',
1
END DECLARE @TableID INT
SELECT
  @TableID = ISNULL(MAX(TableID), 0) + 1
FROM
  TABLES
INSERT INTO
  TABLES(TableID, ChairAmount, isActive)
VALUES
  (@TableID, @Size, @Status)
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Bład edytowania stolika: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- Add table
  -- Remove table
  CREATE PROCEDURE removeTable @TableID int AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      TABLES
    WHERE
      TableID = @TableID
  ) BEGIN;

THROW 52000,
N 'Nie ma takiego stolika.',
1
END
DELETE FROM
  TABLES
WHERE
  TableID = @TableID
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Bład edytowania stolika: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- Remove table
  -- Add address
  AS BEGIN BEGIN TRY DECLARE @CityID int IF NOT EXISTS(
    SELECT
      *
    FROM
      Cities
    WHERE
      CityName LIKE @CityName
  ) BEGIN EXEC addCity @CityName
END
SELECT
  @CityID = CityID
FROM
  Cities
WHERE
  CityName LIKE @CityName
INSERT INTO
  Address(CityID, street, LocalNr, PostalCode)
VALUES
  (@CityID, @Street, @LocalNr, @PostalCode)
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Bład dodania adresu: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- Add address
  -- remove address
  CREATE PROCEDURE removeAddress @AddressID int AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      Address
    WHERE
      AddressID = @AddressID
  ) BEGIN;

THROW 52000,
N 'Nie ma takiego adresu.',
1
END
DELETE FROM
  Address
WHERE
  AddressID = @AddressID
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Bład usuniecia adresu: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- remove address
  -- add person 
  CREATE PROCEDURE addPerson @FirstName varchar(70),
  @LastName varchar(50) AS BEGIN BEGIN TRY
INSERT INTO
  Person(LastName, FirstName)
VALUES
  (@LastName, @FirstName)
END try BEGIN catch DECLARE @msg nvarchar(2048) = N'Bład dodania Osoby: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END
GO
  -- add person
  -- remove person
  CREATE PROCEDURE removePerson @PersonID int AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      Person
    WHERE
      PersonID = @PersonID
  ) BEGIN;

THROW 52000,
N 'Nie ma takiej osoby.',
1
END
DELETE FROM
  Person
WHERE
  PersonID = @PersonID
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Bład usuniecia osoby: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- remove person
  -- add client
  CREATE PROCEDURE addClient @ClientType varchar(1),
  @CityName nvarchar(35),
  @Street nvarchar(70),
  @LocalNr varchar(10),
  @PostalCode char(6),
  @Phone varchar(14),
  @Email varchar(100),
  @FirstName varchar(50) = NULL,
  @LastName varchar(70) = NULL,
  @CompanyName nvarchar(50) = NULL,
  @NIP char(10) = NULL,
  @KRS char(10) = NULL,
  @REGON char(9) = NULL AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF (
    @ClientType NOT LIKE 'C'
    AND @ClientType NOT LIKE 'I'
  ) BEGIN;

THROW 52000,
N 'Nie ma takiego typu klienta!',
1
END IF EXISTS(
  SELECT
    *
  FROM
    Clients
  WHERE
    Phone LIKE @Phone
) BEGIN;

THROW 52000,
N 'Numer telefonu jest już w bazie',
1
END IF EXISTS(
  SELECT
    *
  FROM
    Clients
  WHERE
    Email LIKE @Email
) BEGIN;

THROW 52000,
N'Email jest już w bazie',
1
END IF @CompanyName IS NOT NULL
AND @ClientType LIKE 'C'
AND EXISTS(
  SELECT
    *
  FROM
    Companies
  WHERE
    CompanyName LIKE @CompanyName
) BEGIN;

THROW 52000,
N'Firma jest już w bazie',
1
END IF @KRS IS NOT NULL
AND @ClientType LIKE 'C'
AND EXISTS(
  SELECT
    *
  FROM
    Companies
  WHERE
    KRS LIKE @KRS
) BEGIN;

THROW 52000,
N'KRS jest już w bazie',
1
END IF @NIP IS NOT NULL
AND @ClientType LIKE 'C'
AND EXISTS(
  SELECT
    *
  FROM
    Companies
  WHERE
    NIP LIKE @NIP
) BEGIN;

THROW 52000,
N 'NIP jest już w bazie',
1
END IF @REGON IS NOT NULL
AND @ClientType LIKE 'C'
AND EXISTS(
  SELECT
    *
  FROM
    Companies
  WHERE
    Regon LIKE @REGON
) BEGIN;

THROW 52000,
N 'REGON jest już w bazie',
1
END IF (@ClientType = 'C') BEGIN IF(@NIP IS NULL) BEGIN THROW 52000,
N 'Nip musi być określony dla klienta firmowego!',
1
END IF(@CompanyName IS NULL) BEGIN THROW 52000,
N 'CompanyName musi być określony dla klienta firmowego!',
1
END
END IF (@ClientType = 'I') BEGIN IF(@LastName IS NULL) BEGIN THROW 52000,
N 'Nazwisko musi być określony dla klienta indywidualnego!',
1
END IF(@FirstName IS NULL) BEGIN THROW 52000,
N'Imie musi być określony dla klienta indywidualnego!',
1
END
END DECLARE @AddressID int;

IF NOT EXISTS(
  SELECT
    *
  FROM
    Address
  WHERE
    street LIKE @Street
    AND PostalCode LIKE @PostalCode
    AND LocalNr LIKE @LocalNr
) BEGIN EXEC addAddress @Street,
@LocalNr,
@PostalCode,
@CityName
END
SELECT
  @AddressID = AddressID
FROM
  Address
INSERT INTO
  Clients(AddressID, Phone, Email)
VALUES
  (@AddressID, @Phone, @Email) DECLARE @ClientID int;

SELECT
  @ClientID = ClientID
FROM
  Clients
WHERE
  @AddressID = AddressID
  AND Clients.Phone LIKE @Phone
  AND Clients.Email LIKE @Email IF (@ClientType = 'C') BEGIN
INSERT INTO
  Companies(ClientID, CompanyName, NIP, KRS, Regon)
VALUES
  (@ClientID, @CompanyName, @NIP, @KRS, @REGON)
END IF (@ClientType = 'I') BEGIN EXEC addPerson @FirstName,
@LastName DECLARE @PersonID int
SELECT
  @PersonID = PersonID
FROM
  Person
INSERT INTO
  IndividualClient(ClientID, PersonID)
VALUES
  (@ClientID, @PersonID)
END
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Bład dodania klienta: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- add client
  -- add Product to Menu 
  CREATE PROCEDURE addProductToMenu @Name nvarchar(150),
  @MenuID int,
  @Price money AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      Products
    WHERE
      Name LIKE @Name
  ) BEGIN;

THROW 52000,
N 'Nie ma takiej potrawy',
1
END DECLARE @ProductID int DECLARE @StartDate datetime DECLARE @EndDate datetime
SELECT
  @ProductID = ProductID
FROM
  Products
WHERE
  Name LIKE @Name IF NOT EXISTS(
    SELECT
      *
    FROM
      Menu
    WHERE
      MenuID = @MenuID
  ) BEGIN;

SELECT
  @StartDate = GETDATE()
SELECT
  @EndDate = DATEADD(DAY, 15, @StartDate) EXEC addMenu @MenuID,
  @StartDate,
  @EndDate,
  @Price,
  @ProductID RETURN
END
SELECT
  TOP 1 @StartDate = StartDate
FROM
  Menu
WHERE
  MenuID = @MenuID
SELECT
  TOP 1 @EndDate = endDate
FROM
  Menu
WHERE
  MenuID = @MenuID
INSERT INTO
  Menu(MenuID, startDate, endDate, Price, ProductID)
VALUES
  (
    @MenuID,
    @StartDate,
    @EndDate,
    @Price,
    @ProductID
  )
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Błąd dodania potrawy do menu: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- add Product to Menu 
  -- remove Product From Menu 
  CREATE PROCEDURE removeProductFromMenu @Name nvarchar(150),
  @MenuID int AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      Products
    WHERE
      Name LIKE @Name
  ) BEGIN;

THROW 52000,
N 'Nie ma takiej potrawy',
1
END IF NOT EXISTS(
  SELECT
    *
  FROM
    Menu
  WHERE
    MenuID = @MenuID
) BEGIN;

THROW 52000,
N 'Nie ma takiego menu',
1
END IF NOT EXISTS(
  SELECT
    *
  FROM
    Menu
    INNER JOIN Products P ON P.ProductID = Menu.ProductID
  WHERE
    MenuID = @MenuID
    AND Name LIKE @Name
) BEGIN;

THROW 52000,
N 'Nie ma takiego produktu w menu',
1
END DECLARE @ProductID int
SELECT
  @ProductID = ProductID
FROM
  Products
WHERE
  Name LIKE @Name
DELETE FROM
  Menu
WHERE
  MenuID = @MenuID
  AND ProductID = @ProductID
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Błąd usunięcia potrawy z menu: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  -- remove Product From Menu
  -- add menu 
  CREATE PROCEDURE addMenu @MenuID int,
  @StartDate datetime,
  @EndDate datetime,
  @Price money,
  @ProductID int AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF EXISTS(
    SELECT
      *
    FROM
      Menu
    WHERE
      MenuID = @MenuID
  ) BEGIN;

THROW 52000,
N'Takie menu już istnieje',
1
END IF NOT EXISTS(
  SELECT
    *
  FROM
    Products
  WHERE
    ProductID = @ProductID
) BEGIN;

THROW 52000,
N 'Nie ma takiego produktu',
1
END
INSERT INTO
  Menu(MenuID, startDate, endDate, Price, ProductID)
VALUES
  (
    @MenuID,
    @StartDate,
    @EndDate,
    @Price,
    @ProductID
  )
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Błąd dodania menu: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  CREATE PROCEDURE [create invoice] @OrderID int,
  @InvoiceDate date,
  @PaymentMethodName varchar(50),
  @PaymentStatusName varchar(50),
  @InvoiceID int output AS BEGIN BEGIN TRY IF NOT EXISTS(
    SELECT
      OrderID
    FROM
      Orders
    WHERE
      OrderID = @OrderID
  ) BEGIN;

THROW 52000,
N 'Nie ma takiego zamówienia',
1
END IF NOT EXISTS(
  SELECT
    PaymentName
  FROM
    PaymentMethods
  WHERE
    PaymentName LIKE @PaymentMethodName
) BEGIN;

THROW 52000,
N 'Nie ma takiej metody płatności',
1
END IF NOT EXISTS(
  SELECT
    PaymentStatusName
  FROM
    PaymentStatus
  WHERE
    PaymentStatusName LIKE @PaymentStatusName
) BEGIN;

THROW 52000,
N 'Nie ma takiego statusu płatności',
1
END declare @invoiceNum nvarchar(50) = concat(
  'FV/',
  cast(@OrderID AS nvarchar(50)),
  '/',
  cast(
    year(
      (
        SELECT
          OrderCompletionDate
        FROM
          Orders
        WHERE
          OrderID = @OrderID
      )
    ) AS nvarchar(4)
  )
) declare @ClientID int = (
  SELECT
    ClientID
  FROM
    Orders
  WHERE
    OrderID = @OrderID
) declare @InvoiceIDs TABLE (ID int) declare @PaymentMethodID int
SELECT
  @PaymentMethodID = PaymentMethodID
FROM
  PaymentMethods declare @PaymentStatusID int
INSERT INTO
  Invoice(
    InvoiceNumber,
    InvoiceDate,
    DueDate,
    ClientID,
    PaymentStatusID,
    PaymentMethodID
  ) output inserted.InvoiceID INTO @InvoiceIDs
VALUES
  (
    @invoiceNum,
    @InvoiceDate,
    dateadd(DAY, 12, GETDATE()),
    @ClientID,
    @PaymentStatusID,
    @PaymentMethodID
  )
SELECT
  @InvoiceID = ID
FROM
  @InvoiceIDs RETURN @InvoiceID
END TRY BEGIN catch DECLARE @msg nvarchar(2048) = N'Błąd dodania faktury: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END
GO