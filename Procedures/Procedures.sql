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
  PaymentMethods
WHERE
  PaymentName LIKE @PaymentMethodName declare @PaymentStatusID int
SELECT
  @PaymentStatusID = PaymentStatusID
FROM
  PaymentStatus
WHERE
  PaymentStatusName LIKE @PaymentStatusName
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
  CREATE PROCEDURE [add Payment Status] @PaymentStatusName varchar(50) AS BEGIN BEGIN TRY IF EXISTS(
    SELECT
      PaymentStatusName
    FROM
      PaymentStatus
    WHERE
      PaymentStatus.PaymentStatusName LIKE @PaymentStatusName
  ) BEGIN;

THROW 52000,
N'Taki status istnieje!',
1
END
INSERT INTO
  PaymentStatus(PaymentStatusName)
VALUES
  (@PaymentStatusName)
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Błąd dodania metody płatności do zamówienia: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END
GO
GO
  CREATE PROCEDURE [add Payment Method] @PaymentMethodName varchar(50) AS BEGIN BEGIN TRY IF EXISTS(
    SELECT
      PaymentName
    FROM
      PaymentMethods
    WHERE
      PaymentMethods.PaymentName LIKE @PaymentMethodName
  ) BEGIN;

THROW 52000,
N'Taka metoda istnieje!',
1
END
INSERT INTO
  PaymentMethods(PaymentName)
VALUES
  (@PaymentMethodName)
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Błąd dodania metody płatności do zamówienia: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END
GO
  CREATE PROCEDURE [change payment method for order] @PaymentMethodName varchar(50),
  @OrderID int AS BEGIN BEGIN TRY IF NOT EXISTS(
    SELECT
      OrderID
    FROM
      Orders
    WHERE
      OrderID = @OrderID
  ) BEGIN;

THROW 52000,
'Brak takiego zamowienia',
1
END IF NOT EXISTS(
  SELECT
    PaymentMethodID
  FROM
    PaymentMethods
  WHERE
    PaymentName LIKE @PaymentMethodName
) BEGIN;

THROW 52000,
'Brak takiej metody platnosci',
1
END DECLARE @PaymentMethodID int;

SELECT
  @PaymentMethodID = PaymentMethodID
FROM
  PaymentMethods
WHERE
  PaymentName LIKE @PaymentMethodName
UPDATE
  Orders
SET
  PaymentMethodID = @PaymentMethodID
WHERE
  OrderID = @OrderID
END try BEGIN catch DECLARE @msg nvarchar(2048) = N'Błąd zmiany metody: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END CREATE PROCEDURE [change payment method for invoice] @PaymentMethodName varchar(50),
@InvoiceID int AS BEGIN BEGIN TRY IF NOT EXISTS(
  SELECT
    InvoiceID
  FROM
    Invoice
  WHERE
    InvoiceID = @InvoiceID
) BEGIN;

THROW 52000,
'Brak takiego zamowienia',
1
END IF NOT EXISTS(
  SELECT
    PaymentMethodID
  FROM
    PaymentMethods
  WHERE
    PaymentName LIKE @PaymentMethodName
) BEGIN;

THROW 52000,
'Brak takiej metody platnosci',
1
END DECLARE @PaymentMethodID int;

SELECT
  @PaymentMethodID = PaymentMethodID
FROM
  PaymentMethods
WHERE
  PaymentName LIKE @PaymentMethodName
UPDATE
  Invoice
SET
  PaymentMethodID = @PaymentMethodID
WHERE
  InvoiceID = @InvoiceID
END try BEGIN catch DECLARE @msg nvarchar(2048) = N'Błąd zmiany metody: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END CREATE PROCEDURE [change payment status for invoice] @PaymentStatusName varchar(50),
@InvoiceID int AS BEGIN BEGIN TRY IF NOT EXISTS(
  SELECT
    InvoiceID
  FROM
    Invoice
  WHERE
    InvoiceID = @InvoiceID
) BEGIN;

THROW 52000,
'Brak takiego zamowienia',
1
END IF NOT EXISTS(
  SELECT
    PaymentStatusID
  FROM
    PaymentStatus
  WHERE
    PaymentStatus.PaymentStatusName LIKE @PaymentStatusName
) BEGIN;

THROW 52000,
'Brak takiego statusu platnosci',
1
END DECLARE @PaymentStatusID int;

SELECT
  @PaymentStatusID = PaymentStatusID
FROM
  PaymentStatus
WHERE
  PaymentStatus.PaymentStatusName LIKE @PaymentStatusName
UPDATE
  Invoice
SET
  PaymentStatusID = @PaymentStatusID
WHERE
  InvoiceID = @InvoiceID
END try BEGIN catch DECLARE @msg nvarchar(2048) = N'Błąd zmiany statusu: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END CREATE PROCEDURE [change payment status for order] @PaymentStatusName varchar(50),
@OrderID int AS BEGIN BEGIN TRY IF NOT EXISTS(
  SELECT
    OrderID
  FROM
    Orders
  WHERE
    OrderID = @OrderID
) BEGIN;

THROW 52000,
'Brak takiego zamowienia',
1
END IF NOT EXISTS(
  SELECT
    PaymentStatusID
  FROM
    PaymentStatus
  WHERE
    PaymentStatus.PaymentStatusName LIKE @PaymentStatusName
) BEGIN;

THROW 52000,
'Brak takiego statusu platnosci',
1
END DECLARE @PaymentStatusID int;

SELECT
  @PaymentStatusID = PaymentStatusID
FROM
  PaymentStatus
WHERE
  PaymentStatus.PaymentStatusName LIKE @PaymentStatusName
UPDATE
  Orders
SET
  PaymentStatusID = @PaymentStatusID
WHERE
  OrderID = @OrderID
END try BEGIN catch DECLARE @msg nvarchar(2048) = N'Błąd zmiany statusu: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END CREATE PROCEDURE OrderInsertInstPay @ClientID int,
@OrderCompletionDate DATE,
@PaymentStatusName_ varchar(50),
@PaymentMethodName_ varchar(50),
@OrderStatus varchar(15),
@StaffID int AS BEGIN BEGIN TRY IF NOT EXISTS(
  SELECT
    PaymentStatusID
  FROM
    PaymentStatus
  WHERE
    PaymentStatusName LIKE @PaymentStatusName_
) BEGIN;

THROW 52000,
'Nie ma takiego statusu!',
1
END IF NOT EXISTS(
  SELECT
    PaymentMethods.PaymentName
  FROM
    PaymentMethods
  WHERE
    PaymentMethods.PaymentName LIKE @PaymentMethodName_
) BEGIN;

THROW 52000,
'Nie ma takiej metody!',
1
END IF NOT EXISTS(
  SELECT
    StaffID
  FROM
    Staff
  WHERE
    StaffID = @StaffID
) BEGIN;

THROW 52000,
'Nie ma takiego pracownika!',
1
END Declare @OrderIDTable TABLE (Id int) Declare @OrderID int DECLARE @PaymentMethodID int DECLARE @PaymentStatusID int
SELECT
  @PaymentStatusID = PaymentStatusID
FROM
  PaymentStatus
WHERE
  PaymentStatusName LIKE @PaymentStatusName_
SELECT
  @PaymentMethodID = PaymentMethods.PaymentName
FROM
  PaymentMethods
WHERE
  PaymentMethods.PaymentName LIKE @PaymentMethodName_
INSERT INTO
  Orders (
    ClientID,
    PaymentStatusID,
    PaymentMethodID,
    staffID,
    OrderSum,
    OrderCompletionDate,
    OrderStatus,
    OrderDate
  ) OUTPUT inserted.OrderID INTO @OrderIDTable
VALUES
  (
    @ClientID,
    @PaymentStatusID,
    @PaymentMethodID,
    @StaffID,
    0.0,
    @OrderCompletionDate,
    @OrderStatus,
    GETDATE()
  );

SELECT
  @OrderID = Id
FROM
  @OrderIDTable declare @InvoiceID int EXEC dbo.[create invoice] @OrderID = @OrderID,
  @InvoiceDate = @OrderCompletionDate,
  @PaymentMethodName = @PaymentMethodName_,
  @PaymentStatusName = @PaymentStatusName_,
  @InvoiceID = @InvoiceID output
UPDATE
  [Orders]
SET
  InvoiceID = @InvoiceID
WHERE
  OrderID = @OrderID RETURN @OrderID
END try BEGIN catch DECLARE @msg nvarchar(2048) = N'Błąd dodania zamowienia: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END;

GO
  CREATE PROCEDURE OrderInsertMonthPay @ClientID int,
  @OrderCompletionDate DATE,
  @PaymentStatusName_ varchar(50),
  @PaymentMethodName_ varchar(50),
  @OrderStatus varchar(15),
  @StaffID int AS BEGIN BEGIN TRY IF NOT EXISTS(
    SELECT
      PaymentStatusID
    FROM
      PaymentStatus
    WHERE
      PaymentStatusName LIKE @PaymentStatusName_
  ) BEGIN;

THROW 52000,
'Nie ma takiego statusu!',
1
END IF NOT EXISTS(
  SELECT
    PaymentMethods.PaymentName
  FROM
    PaymentMethods
  WHERE
    PaymentMethods.PaymentName LIKE @PaymentMethodName_
) BEGIN;

THROW 52000,
'Nie ma takiej metody!',
1
END IF NOT EXISTS(
  SELECT
    StaffID
  FROM
    Staff
  WHERE
    StaffID = @StaffID
) BEGIN;

THROW 52000,
'Nie ma takiego pracownika!',
1
END Declare @OrderIDTable TABLE (Id int) Declare @OrderID int DECLARE @PaymentMethodID int DECLARE @PaymentStatusID int
SELECT
  @PaymentStatusID = PaymentStatusID
FROM
  PaymentStatus
WHERE
  PaymentStatusName LIKE @PaymentStatusName_
SELECT
  @PaymentMethodID = PaymentMethods.PaymentName
FROM
  PaymentMethods
WHERE
  PaymentMethods.PaymentName LIKE @PaymentMethodName_
INSERT INTO
  Orders (
    ClientID,
    PaymentStatusID,
    PaymentMethodID,
    staffID,
    OrderSum,
    OrderCompletionDate,
    OrderStatus,
    OrderDate
  ) OUTPUT inserted.OrderID INTO @OrderIDTable
VALUES
  (
    @ClientID,
    @PaymentStatusID,
    @PaymentMethodID,
    @StaffID,
    0.0,
    @OrderCompletionDate,
    @OrderStatus,
    GETDATE()
  );

SELECT
  @OrderID = Id
FROM
  @OrderIDTable declare @startOfMonth date = cast(
    DATEADD(
      MONTH,
      DATEDIFF(MONTH, 0, @OrderCompletionDate) + 1,
      0
    ) AS date
  ) declare @InvoiceID int
SELECT
  @InvoiceID = InvoiceID
FROM
  Invoice
WHERE
  ClientID = @ClientID
  AND MONTH(InvoiceDate) = MONTH(@startOfMonth)
  AND year(InvoiceDate) = year(@startOfMonth) IF @InvoiceID IS NULL BEGIN;

EXEC dbo.[create invoice] @OrderID = @OrderID,
@InvoiceDate = @startOfMonth,
@PaymentMethodName = @PaymentMethodName_,
@PaymentStatusName = @PaymentStatusName_,
@InvoiceID = @InvoiceID output
END
UPDATE
  [Orders]
SET
  InvoiceID = @InvoiceID
WHERE
  OrderID = @OrderID RETURN @OrderID
END try BEGIN catch DECLARE @msg nvarchar(2048) = N'Błąd dodania zamowienia: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END;

GO
  CREATE PROCEDURE addCity @CityName nvarchar(35) AS
INSERT INTO
  Cities (CityName)
VALUES
  (@CityName);

GO
;

CREATE PROCEDURE addStaffMember @LastName nvarchar(50),
@FirstName nvarchar(70),
@Position varchar(50),
@Email varchar(100),
@Phone varchar(14),
@AddressID int AS
INSERT INTO
  Staff (
    LastName,
    FirstName,
    Position,
    Email,
    Phone,
    AddressID
  )
VALUES
  (
    @LastName,
    @FirstName,
    @Position,
    @Email,
    @Phone,
    @AddressID
  );

GO
;

CREATE PROCEDURE addCategory @CategoryName nvarchar(50),
@Description nvarchar(150) AS
INSERT INTO
  Category (CategoryName, Description)
VALUES
  (@CategoryName, @Description);

GO
;

CREATE PROCEDURE addProduct @CategoryID int,
@Name nvarchar(50),
@Description nvarchar(150),
@IsAvailable bit AS
INSERT INTO
  Products (CategoryID, Name, Description, IsAvailable)
VALUES
  (@CategoryID, @Name, @Description, @IsAvailable);

GO
;

CREATE PROCEDURE removeCity @CityID int AS
DELETE FROM
  Cities
WHERE
  CityID = @CityID
GO
;

CREATE PROCEDURE removeCategory @CategoryID int AS
DELETE FROM
  Category
WHERE
  CategoryID = @CategoryID
GO
;

CREATE PROCEDURE removeProduct @ProductID int AS
DELETE FROM
  Products
WHERE
  ProductID = @ProductID
GO
;

-- null->accepted->pending->completed->picked (jesli na wynos)
-- null->denied (zwrot srodkow)
CREATE PROCEDURE denyOrder @OrderID int AS
UPDATE
  Orders
SET
  OrderStatus = 'denied'
WHERE
  OrderID = @OrderID;

GO
;

-- pracownicy mają working hours, muszą chyba kiedyś spać?
CREATE PROCEDURE AssignWaiterToOrder @OrderID int,
@StaffId int AS
UPDATE
  Orders
SET
  StaffId = @StaffId
WHERE
  OrderID = @OrderID;

GO
;

-- who accepts reservation or denies it
CREATE PROCEDURE AssignReservationManOrWomanToResrvation @ReservationID int,
@StaffId int AS
UPDATE
  Reservation
SET
  StaffId = @StaffId
WHERE
  ReservationID = @ReservationID;

GO
;

-- jeden payment dotyczy wielu zamowien, co jezeli tylko czesc z nich jest anulowana, a czesc nie jest...
CREATE PROCEDURE refundWasMade @PaymentStatusID int AS
UPDATE
  PaymentStatus
SET
  PaymentStatusName = 'Refunded'
WHERE
  PaymentStatusID = @PaymentStatusID;

GO
;

CREATE PROCEDURE showBestDiscountTemporary @ClientID int AS
SELECT
  max(DiscountValue)
FROM
  IndividualClient I
  JOIN Discounts D ON I.ClientID = D.ClientID
  JOIN DiscountsVar DV ON DV.VarID = D.VarID
WHERE
  DiscountType = 'Temporary'
  AND I.ClientID = @ClientID
  AND AppliedDate <= getdate() <= dateadd(DAY, ValidityPeriod, AppliedDate) -- Temporary Discounts must have endDate
GO
  CREATE PROCEDURE showBestDiscountPermanent @ClientID int AS
SELECT
  max(DiscountValue)
FROM
  IndividualClient I
  JOIN Discounts D ON I.ClientID = D.ClientID
  JOIN DiscountsVar DV ON DV.VarID = D.VarID
WHERE
  DiscountType = 'Permanent'
  AND I.ClientID = @ClientID
GO
;

--zmiana statusu rezerwacji
CREATE PROCEDURE changeReservationStatus @ReservationID int,
@Status varchar(15) AS BEGIN
SET
  NOCOUNT ON BEGIN TRY BEGIN
UPDATE
  Reservation
SET
  STATUS = @Status
WHERE
  Reservation.ReseravtionID = @ReservationID
END
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = N'Błąd edytowania rezerwacji: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END CATCH --Dodawanie dania do zamówienia
CREATE PROCEDURE AddProductToOrder @OrderID int,
@Quantity int,
@ProductName nvarchar(50) AS BEGIN
SET
  NOCOUNT ON BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      Products
    WHERE
      Name = @ProductName
  ) BEGIN;

THROW 52000,
'Nie ma takiej potrawy',
1
END IF NOT EXISTS(
  SELECT
    *
  FROM
    Orders
  WHERE
    OrderID = @OrderID
) BEGIN;

THROW 52000,
'Nie ma takiego zamowienia',
1
END IF NOT EXISTS(
  SELECT
    *
  FROM
    Menu AS M
    INNER JOIN Products P ON P.ProductID = M.MenuID
  WHERE
    P.Name = @ProductName
    AND (
      M.startDate <= GETDATE()
      AND (
        M.endDate = NULL
        OR M.endDate >= GETDATE()
      )
    ) BEGIN;

THROW 52000,
'Nie mozna zamowic tego produktu, gdyz nie ma go obecnie w menu',
1
END BEGIN DECLARE @OrderDate DATE
SELECT
  @OrderDate = OrderDate
FROM
  Orders
WHERE
  OrderID = @OrderID
END IF DATEPART(WEEKDAY, @OrderDate) != 4
AND DATEPART(WEEKDAY, @OrderDate) != 5
AND DATEPART(WEEKDAY, @OrderDate) != 6 BEGIN;

THROW 52000,
N 'Nieprawidłowa data złożenia zamówienia na owoce morza',
1
END DECLARE @ProductID INT
SELECT
  @ProductID = ProductID
FROM
  Products
WHERE
  Name = @ProductName
INSERT INTO
  OrderDetails(OrderID, Quantity, ProductID)
VALUES
  (@OrderID, @Quantity, @ProductID)
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = 'Błąd dodania produktu do zamowienia: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH
END
GO
  --Listowanie pracowników przypisanych do danego zamówienia
  CREATE PROCEDURE EmployeesAssignedToTheOrder @OrderID int AS BEGIN TRY IF NOT EXISTS(
    SELECT
      *
    FROM
      Orders
    WHERE
      OrderID = @OrderID
  ) BEGIN;

THROW 52000,
'Nie ma takiego zamowienia',
1
END
SELECT
  O.*,
  S.*
FROM
  Staff AS S
  INNER JOIN Orders O ON O.StaffID = S.StaffID
WHERE
  O.OrderID = @OrderID
END TRY BEGIN CATCH DECLARE @msg nvarchar(2048) = 'Błąd wypisywania pracownikow:' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END CATCH --
CREATE PROCEDURE dbo.get_dishes_for_day @data Date AS BEGIN
SET
  NOCOUNT ON BEGIN TRY
SELECT
  o.OrderID,
  cast(OrderCompletionDate AS Date) AS 'OrderCompletionDate',
  P.Name,
  sum(OD.Quantity) AS 'Quantity'
FROM
  Orders o
  INNER JOIN OrderDetails OD ON o.OrderID = OD.OrderID
  INNER JOIN Products P ON OD.ProductID = P.ProductID
WHERE
  cast(OrderCompletionDate AS Date) = @data
GROUP BY
  o.OrderID,
  o.OrderCompletionDate,
  P.Name
END try BEGIN catch DECLARE @msg varchar(2048) = N'Bład wyświetlenia danych: ' + ERROR_MESSAGE();

THROW 52000,
@msg,
1
END catch
END
GO