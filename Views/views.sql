-- Current menu view --

create view dbo.CurrentMenu as
    select MenuID, Price, Name, Description from Menu inner join Products P on P.ProductID = Menu.ProductID
    where ((getdate() >= startDate) and (getdate() <= endDate)) or ((getdate() >= startDate) and endDate is null) ;

-- Current menu view --


-- Current reservation vars --

create view dbo.CurrentReservationVars as
    select WZ as [Minimalna liczba zamowien], WK as [Minimalna kwota dla zamowienia], startDate, isnull(endDate, 'Brak daty konca') from ReservationVar
    where ((getdate() >= startDate) and (getdate() <= endDate)) or ((getdate() >= startDate) and endDate is null);

-- unpaid invoices  --

create view dbo.unPaidInvoices as
    select  InvoiceNumber as [Numer faktury], InvoiceDate as [Data wystawienia],
            DueDate as [Data terminu zaplaty], concat(LastName, ' ',FirstName),
            Phone, Email, concat(CityName, ' ',street,' ', LocalNr), PostalCode from Invoice
        inner join Clients C on C.ClientID = Invoice.ClientID
        inner join Address A on C.AddressID = A.AddressID
        inner join IndividualClient IC on C.ClientID = IC.ClientID
        inner join Person P on P.PersonID = IC.PersonID
        inner join Cities C2 on C2.CityID = A.CityID
        inner join PaymentStatus PS on Invoice.PaymentStatusID = PS.PaymentStatusID
    where ((InvoiceDate >= getdate()) and (getdate() <= DueDate ) and PaymentStatusName like 'Unpaid');

-- unpaid invoices  --

-- withdrawn products --

create view dbo.withdrawnFoods as
    select Name, P.Description, C.CategoryName from Products P
        inner join Category C on C.CategoryID = P.CategoryID where P.IsAvailable = 0

-- withdrawn products --

-- active products --

create view dbo.withdrawnFoods as
    select Name, P.Description, C.CategoryName from Products P
        inner join Category C on C.CategoryID = P.CategoryID where P.IsAvailable = 1

-- active products --

-- Active Tables --
-- dostępne dla klientów --
create view dbo.ActiveTables as
    select TableID, ChairAmount from Tables
        where isActive = 1
-- Active Tables --

-- Not reserved Tables --

create view dbo.[Not reserved Tables] as
    select TableID, ChairAmount from Tables
        left join ReservationDetails RD on Tables.TableID = RD.TableID
        inner join ReservationCompany RC on RC.ReservationID = RD.ReservationID
        inner join Reservation R2 on RC.ReservationID = R2.ReservationID
            where RD.ReservationID is null and (getdate() >= startDate) and (getdate() >= endDate)
    union
    select TableID, ChairAmount from Tables
        left join ReservationDetails RD on Tables.TableID = RD.TableID
        inner join ReservationIndividual RI on RI.ReservationID = RD.ReservationID
        inner join Reservation R3 on RD.ReservationID = R3.ReservationID
            where RD.ReservationID is null and (getdate() >= startDate) and (getdate() >= endDate)

-- Not reserved Tables --

-- Kto wydał dane zamówienie
create or alter view dbo.Waiters as
    select FirstName + ' ' + LastName as Name, OrderID as id
    from Staff
             join Orders O on Staff.StaffID = O.staffID
    where Position = 'waiter'
       or Position = 'waitress';
go

-- Jakie zamówienia są na wynos
create or alter view dbo.AllTakeaways as
    select TakeawayID,
           PrefDate,
           OrderID,
           ClientID,
           PaymentStatusID,
           concat(S.LastName, ' ',S.FirstName) as 'Dane kelnera',
           Position,
           OrderSum,
           OrderDate,
           OrderCompletionDate,
           OrderStatus
    from OrdersTakeaways
            join Orders O on OrdersTakeaways.TakeawaysID = O.TakeawayID
            join Staff S on O.staffID = S.StaffID
go

-- Jakie zamówienia są w trakcie przygotowywania
create or alter view dbo.OrdersToPrepare as
    select OrderID, ClientID, TakeawayID, PaymentStatusName, PM.PaymentName,
           concat(S.LastName, ' ',S.FirstName) as 'Dane kelnera',
            OrderSum, OrderDate, PrefDate
    from Orders join OrdersTakeaways OT on Orders.TakeawayID = OT.TakeawaysID
        inner join PaymentStatus PS on PS.PaymentStatusID = Orders.PaymentStatusID
        inner join PaymentMethods PM on PS.PaymentMethodID = PM.PaymentMethodID
        inner join Staff S on Orders.staffID = S.StaffID
    where (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)) and OrderStatus = 'pending')
go

-- Ile jest zamówień które będą realizowane jako owoce morza i które to są grupowane po klientach
create or alter view dbo.SeeFoodOrdersByClient as
    select count(OD.OrderID) as 'Liczba zamowien z owocami morza', Orders.OrderID
    from Orders
        join OrderDetails OD on Orders.OrderID = OD.OrderID
        join Products P on P.ProductID = OD.ProductID join Category C on C.CategoryID = P.CategoryID
    where CategoryName='sea food' and (OrderStatus not like 'denied') and (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)))
    group by CategoryName, Orders.OrderID
go

-- Ile jest zamówień które będą realizowane jako owoce morza i które to są 
create or alter view dbo.SeeFoodOrders as
    select count(OD.OrderID) as 'Liczba zamowien z owocami morza'
    from Orders
        join OrderDetails OD on Orders.OrderID = OD.OrderID
        join Products P on P.ProductID = OD.ProductID join Category C on C.CategoryID = P.CategoryID
    where CategoryName='sea food' and (OrderStatus not like 'denied') and (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)))
    group by CategoryName
go


-- Aktualnie nałożone zniżki na klientów
create or alter view CurrentDiscounts as
    select FirstName,LastName, IC.ClientID, DiscountID, AppliedDate, startDate, endDate, DiscountType,
           DiscountValue, MinimalOrders, MinimalAggregateValue, ValidityPeriod
    from DiscountsVar join Discounts on DiscountsVar.VarID = Discounts.VarID
        join IndividualClient IC on Discounts.ClientID = IC.ClientID
        join Person P on P.PersonID = IC.PersonID
    where IC.ClientID is not null and (((getdate() >= startDate) and (getdate() <= endDate)) or ((getdate() >= startDate) and (endDate is null)))
go

-- informacje na temat wszystkich przyznanych zniżek
create or alter view AllDiscounts as
    select IC.PersonID, LastName, FirstName,IC.ClientID, DiscountsVar.VarID, DiscountType, MinimalOrders, MinimalAggregateValue, ValidityPeriod, DiscountValue, startDate, endDate, DiscountID, AppliedDate
    from DiscountsVar 
        join Discounts on DiscountsVar.VarID = Discounts.VarID 
        join IndividualClient IC on Discounts.ClientID = IC.ClientID 
        join Person P on P.PersonID = IC.PersonID
    where IC.ClientID is not null
go
-- Dania wymagane na dzisiaj na wynos

create or alter view DishesInProgressTakeaways as
    select  Name, count(Products.ProductID) as 'Liczba zamowien', sum(Quantity) as 'Liczba sztuk'
    from Products join OrderDetails OD on Products.ProductID = OD.ProductID
        join Orders on OD.OrderID = Orders.OrderID
        join OrdersTakeaways OT on Orders.TakeawayID = OT.TakeawaysID
    where (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate))
      or (OrderCompletionDate is null and (getdate() >= OrderDate)))
      and OrderStatus not like 'denied' and (Orders.OrderStatus not like 'denied' or Orders.OrderStatus not like 'cancelled')
    group by Name
go

-- Dania wymagane na dzisiaj w rezerwacji
create or alter view DishesInProgressReservation as
    select Name, count(Products.ProductID) as 'Liczba zamowien', sum(Quantity) as 'Liczba sztuk'
    from Products
        join OrderDetails OD on Products.ProductID = OD.ProductID
        join Orders on OD.OrderID = Orders.OrderID
        join Reservation R2 on Orders.ReservationID = R2.ReservationID
    where (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) 
      or (OrderCompletionDate is null and (getdate() >= OrderDate)))
      and OrderStatus not like 'denied' and (R2.Status not like 'denied' or R2.Status not like 'cancelled')
    group by Name
go