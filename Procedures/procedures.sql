CREATE PROCEDURE addCity @CityID char(3), @CityName nvarchar(35)
AS
INSERT INTO Cities (CityID, CityName)
VALUES (@CityID, @CityName);
GO;


CREATE PROCEDURE addStaffMember @LastName nvarchar(50), @FirstName nvarchar(70), @Position varchar(50),
                                @Email varchar(100), @Phone varchar(14), @AddressID int
AS
INSERT INTO Staff (LastName, FirstName, Position, Email, Phone, AddressID)
VALUES (@LastName, @FirstName, @Position, @Email, @Phone, @AddressID);
GO;

CREATE PROCEDURE addCategory @CategoryName nvarchar(50), @Description nvarchar(150)
AS
INSERT INTO Category (CategoryName, Description)
VALUES (@CategoryName, @Description);
GO;

CREATE PROCEDURE addProduct @CategoryID int, @Name nvarchar(50), @Description nvarchar(150), @IsAvailable bit
AS
INSERT INTO Products (CategoryID, Name, Description, IsAvailable)
VALUES (@CategoryID, @Name, @Description, @IsAvailable);
GO;

CREATE PROCEDURE removeCity @CityID char(3)
AS
Delete
from Cities
where CityID = @CityID
GO;

CREATE PROCEDURE removeCategory @CategoryID int
AS
Delete
from Category
where CategoryID = @CategoryID
GO;

CREATE PROCEDURE removeProduct @ProductID int
AS
Delete
from Products
where ProductID= @ProductID
GO;
-- null->accepted->pending->completed->picked (jesli na wynos)
-- null->denied (zwrot srodkow)
CREATE PROCEDURE denyOrder @OrderID int
AS
UPDATE Orders
SET OrderStatus='denied'
WHERE OrderID = @OrderID;
GO;

-- pracownicy mają working hours, muszą chyba kiedyś spać?
CREATE PROCEDURE AssignWaiterToOrder @OrderID int, @StaffId int
AS
UPDATE Orders
SET StaffId=@StaffId
WHERE OrderID = @OrderID;
GO;

-- who accepts reservation or denies it
CREATE PROCEDURE AssignReservationManOrWomanToResrvation @ReservationID int, @StaffId int
AS
UPDATE Reservation
SET StaffId=@StaffId
WHERE ReservationID = @ReservationID;
GO;

-- jeden payment dotyczy wielu zamowien, co jezeli tylko czesc z nich jest anulowana, a czesc nie jest...
CREATE PROCEDURE refundWasMade @PaymentStatusID int
AS
UPDATE PaymentStatus
SET PaymentStatusName='Refunded'
WHERE PaymentStatusID = @PaymentStatusID;
GO;

CREATE PROCEDURE showBestDiscountTemporary @ClientID int
AS
select max(DiscountValue)
from IndividualClient I
         join Discounts D on I.ClientID = D.ClientID
         join DiscountsVar DV on DV.VarID = D.VarID
where DiscountType = 'Temporary'
  and I.ClientID = @ClientID
  and startDate <= getdate() <= endDate
-- Temporary Discounts must have endDate
GO
CREATE PROCEDURE showBestDiscountPermanent @ClientID int
AS
select max(DiscountValue)
from IndividualClient I
         join Discounts D on I.ClientID = D.ClientID
         join DiscountsVar DV on DV.VarID = D.VarID
where DiscountType = 'Permanent'
  and I.ClientID = @ClientID
GO;
