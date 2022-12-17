-- Kto wydał dane zamówienie
create or alter view dbo.Waiter as
    select FirstName + ' ' + LastName as Name, OrderID as id
    from Staff
             join Orders O on Staff.StaffID = O.staffID
    where Position = 'waiter'
       or Position = 'waitress';

-- Jakie zamówienia są na wynos
create or alter view dbo.AllTakeaways as
    select TakeawayID,
           PrefDate,
           OrderID,
           ClientID,
           PaymentStatusID,
           staffID,
           OrderSum,
           OrderDate,
           OrderCompletionDate,
           OrderStatus
    from OrdersTakeaways
             join Orders O on OrdersTakeaways.TakeawaysID = O.TakeawayID;

-- Jakie zamówienia są w trakcie przygotowywania
create or alter view OrdersToPrepare as
    select *
    from Orders join OrdersTakeaways OT on Orders.TakeawayID = OT.TakeawaysID
    where OrderCompletionDate is null

-- Ile jest zamówień które będą realizowane jako owoce morza i które to są
create or alter view SeeFood as
    select count(OD.OrderID)
    from Orders join OrderDetails OD on Orders.OrderID = OD.OrderID join Products P on P.ProductID = OD.ProductID join Category C on C.CategoryID = P.CategoryID
    where CategoryName='sea food' and OrderCompletionDate is null
    group by CategoryName
    union
    select OD.OrderID
    from Orders join OrderDetails OD on Orders.OrderID = OD.OrderID join Products P on P.ProductID = OD.ProductID join Category C on C.CategoryID = P.CategoryID
    where CategoryName='sea food' and OrderCompletionDate is null

-- Aktualnie nałożone zniżki na klientów
create or alter view CurrentDiscounts as
    select P.PersonID,FirstName,LastName,IC.ClientID,DiscountID,AppliedDate,startDate,endDate,DiscountType,DiscountValue
    from DiscountsVar join Discounts on DiscountsVar.VarID = Discounts.VarID join IndividualClient IC on Discounts.ClientID = IC.ClientID join Person P on P.PersonID = IC.PersonID
    where IC.ClientID is not null and (getdate() >= startDate) and (getdate() <= endDate)

-- informacje na temat wszystkich przyznanych zniżek
create or alter view AllDiscounts as
    select IC.PersonID, LastName, FirstName,IC.ClientID, DiscountsVar.VarID, DiscountType, MinimalOrders, MinimalAggregateValue, ValidityPeriod, DiscountValue, startDate, endDate, DiscountID, AppliedDate
    from DiscountsVar join Discounts on DiscountsVar.VarID = Discounts.VarID join IndividualClient IC on Discounts.ClientID = IC.ClientID join Person P on P.PersonID = IC.PersonID
    where IC.ClientID is not null

-- Dania wymagane na dzisiaj na wynos
create or alter view DishesInProgressTakeaways as
    select count(Quantity)
    from Products join OrderDetails OD on Products.ProductID = OD.ProductID join Orders on OD.OrderID = Orders.OrderID join OrdersTakeaways OT on Orders.TakeawayID = OT.TakeawaysID
    where Day(PrefDate)=DAY(getdate()) and OrderStatus='pending'
    group by Products.ProductID

-- Dania wymagane na dzisiaj w rezerwacji
create or alter view DishesInProgressReservation as
    select count(Quantity)
    from Products join OrderDetails OD on Products.ProductID = OD.ProductID join Orders on OD.OrderID = Orders.OrderID join Reservation R2 on Orders.ReservationID = R2.ReservationID
    where Day(startDate)=DAY(getdate()) and OrderStatus='pending'
    group by Products.ProductID