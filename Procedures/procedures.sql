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