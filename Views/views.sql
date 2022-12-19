-- Current menu view --

create view dbo.CurrentMenu as
    select MenuID, Price, Name, Description from Menu inner join Products P on P.ProductID = Menu.ProductID
    where ((getdate() >= startDate) and (getdate() <= endDate)) or ((getdate() >= startDate) and endDate is null) ;
go
-- Current menu view --


-- Current reservation vars --

create view dbo.CurrentReservationVars as
    select WZ as [Minimalna liczba zamowien], WK as [Minimalna kwota dla zamowienia], startDate, isnull(convert(varchar(20), endDate, 120), 'Obowiązuje zawsze') as 'Koniec menu'
    from ReservationVar
    where ((getdate() >= startDate) and (getdate() <= endDate)) or ((getdate() >= startDate) and endDate is null);
go
-- unpaid invoices  Individuals--

create view dbo.unPaidInvoicesIndividuals as
    select  InvoiceNumber as [Numer faktury], InvoiceDate as [Data wystawienia],
            DueDate as [Data terminu zaplaty], concat(LastName, ' ',FirstName) as [Dane],
            Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode
    from Invoice
        inner join Clients C on C.ClientID = Invoice.ClientID
        inner join Address A on C.AddressID = A.AddressID
        inner join IndividualClient IC on C.ClientID = IC.ClientID
        inner join Person P on P.PersonID = IC.PersonID
        inner join Cities C2 on C2.CityID = A.CityID
        inner join PaymentStatus PS on Invoice.PaymentStatusID = PS.PaymentStatusID
    where PaymentStatusName like 'Unpaid'; -- system will change status
go
-- unpaid invoices  Individuals--

-- unpaid invoices  Company--

create view dbo.unPaidInvoicesCompanies as
    select  InvoiceNumber as [Numer faktury], InvoiceDate as [Data wystawienia],
            DueDate as [Data terminu zaplaty], CompanyName, NIP, isnull(KRS, 'Brak') as [KRS], isnull(Regon, 'Brak') as [Regon],
            Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode
    from Invoice
        inner join Clients C on C.ClientID = Invoice.ClientID
        inner join Companies CO on CO.ClientID = C.ClientID
        inner join Address A on C.AddressID = A.AddressID
        inner join Cities C2 on C2.CityID = A.CityID
        inner join PaymentStatus PS on Invoice.PaymentStatusID = PS.PaymentStatusID
    where (PaymentStatusName like 'Unpaid');
go
-- unpaid invoices  Company--

-- withdrawn products --

create view dbo.withdrawnProducts as
    select Name, P.Description, C.CategoryName from Products P
        inner join Category C on C.CategoryID = P.CategoryID where P.IsAvailable = 0
go

-- withdrawn products --

-- active products --
create view dbo.ActiveProducts as
    select Name, P.Description, C.CategoryName from Products P
        inner join Category C on C.CategoryID = P.CategoryID where P.IsAvailable = 1
go
-- active products --

-- Active Tables --
-- dostępne dla klientów --

create view dbo.ActiveTables as
    select TableID, ChairAmount from Tables
        where isActive = 1
go

-- Active Tables --

-- Not reserved Tables --

create view dbo.[Not reserved Tables] as
    select TableID, ChairAmount
    from Tables
        where TableID not in(select ReservationDetails.TableID
            from ReservationDetails
                inner join ReservationCompany RC on RC.ReservationID = ReservationDetails.ReservationID
                inner join Reservation R2 on RC.ReservationID = R2.ReservationID
            where (getdate() >= startDate) and (getdate() <= endDate) and (Status not like 'cancelled' and Status not like 'denied') and isActive = 1)
union

    select TableID, ChairAmount
    from Tables
        where TableID not in(select ReservationDetails.TableID
            from ReservationDetails
                inner join ReservationIndividual RC on RC.ReservationID = ReservationDetails.ReservationID
                inner join Reservation R2 on RC.ReservationID = R2.ReservationID
            where (getdate() >= startDate) and (getdate() <= endDate) and (Status not like 'cancelled' and Status not like 'denied') and isActive = 1)
go
-- Not reserved Tables --

-- weekly raport about tables --

CREATE VIEW dbo.TablesWeekly AS
    SELECT YEAR(R2.StartDate) as year,
        DATEPART(iso_week, R2.StartDate) as week,
        T.TableID as table_id,
        T.ChairAmount as table_size,
        COUNT(RD.TableID) as how_many_times_reserved
    FROM Tables T
        INNER JOIN ReservationDetails RD on T.TableID = RD.TableID
        inner join ReservationIndividual RI on RI.ReservationID = RD.ReservationID
        INNER JOIN Reservation R2 on RD.ReservationID = R2.ReservationID
    where (Status not like 'cancelled' and Status not like 'denied')
    GROUP BY YEAR(R2.StartDate), DATEPART(iso_week, R2.StartDate), T.TableID, T.ChairAmount
union
    SELECT YEAR(R2.StartDate) as year,
        DATEPART(iso_week , R2.StartDate) as week,
        T.TableID as table_id,
        T.ChairAmount as table_size,
        COUNT(RD.TableID) as how_many_times_reserved
    FROM Tables T
        INNER JOIN ReservationDetails RD on T.TableID = RD.TableID
        inner join ReservationCompany RI on RI.ReservationID = RD.ReservationID
        INNER JOIN Reservation R2 on RD.ReservationID = R2.ReservationID
    where (Status not like 'cancelled' and Status not like 'denied')
    GROUP BY YEAR(R2.StartDate), DATEPART(iso_week, R2.StartDate), T.TableID, T.ChairAmount
go
-- weekly raport about tables --

-- monthly raport about tables --

CREATE VIEW dbo.TablesMonthly AS
    SELECT YEAR(R2.StartDate) as year,
        DATEPART(month , R2.StartDate) as month,
        T.TableID as table_id,
        T.ChairAmount as table_size,
        COUNT(RD.TableID) as how_many_times_reserved
    FROM Tables T
        INNER JOIN ReservationDetails RD on T.TableID = RD.TableID
        inner join ReservationIndividual RI on RI.ReservationID = RD.ReservationID
        INNER JOIN Reservation R2 on RD.ReservationID = R2.ReservationID
    where (Status not like 'cancelled' and Status not like 'denied')
    GROUP BY YEAR(R2.StartDate), DATEPART(month, R2.StartDate), T.TableID, T.ChairAmount
union
    SELECT YEAR(R2.StartDate) as year,
        DATEPART(month, R2.StartDate) as month,
        T.TableID as table_id,
        T.ChairAmount as table_size,
        COUNT(RD.TableID) as how_many_times_reserved
    FROM Tables T
        INNER JOIN ReservationDetails RD on T.TableID = RD.TableID
        inner join ReservationCompany RI on RI.ReservationID = RD.ReservationID
        INNER JOIN Reservation R2 on RD.ReservationID = R2.ReservationID
    where (Status not like 'cancelled' and Status not like 'denied')
    GROUP BY YEAR(R2.StartDate), DATEPART(month, R2.StartDate), T.TableID, T.ChairAmount
go

-- monthly raport about tables --

-- takeaway orders not picked Individuals--

create view dbo.[takeaways orders not picked Individuals] as
    select PrefDate as [Data odbioru], concat(LastName, ' ',FirstName) as [Dane],
           Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode,
            OrderID, OrderDate, OrderCompletionDate, OrderSum
        from OrdersTakeaways OT
            inner join Orders O on OT.TakeawaysID = O.TakeawayID
            inner join Clients C on O.ClientID = C.ClientID
            inner join IndividualClient IC on C.ClientID = IC.ClientID
            inner join Person P on IC.PersonID = P.PersonID
            inner join Address A on C.AddressID = A.AddressID
            inner join Cities C2 on A.CityID = C2.CityID
        where OrderStatus like 'Completed' and (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)))
go
-- takeaways orders not picked Individuals--

-- takeaways orders not picked Companies--

create view dbo.[takeaways orders not picked Companies] as
    select PrefDate as [Data odbioru], CompanyName, NIP, isnull(KRS, 'Brak') as [KRS], isnull(Regon, 'Brak') as [Regon],
           Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode,
            OrderID, OrderDate, OrderCompletionDate, OrderSum
    from OrdersTakeaways OT
        inner join Orders O on OT.TakeawaysID = O.TakeawayID
        inner join Clients C on O.ClientID = C.ClientID
        inner join Companies CO on C.ClientID = CO.ClientID
        inner join Address A on C.AddressID = A.AddressID
        inner join Cities C2 on A.CityID = C2.CityID
    where OrderStatus like 'Completed' and (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)))
go
-- takeaways orders not picked Companies--


-- takeaway orders  Individuals--

create view dbo.[takeaways orders Individuals] as
    select PrefDate as [Data odbioru], concat(LastName, ' ',FirstName) as [Dane],
           Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode,
           OrderID, OrderDate, OrderCompletionDate, OrderStatus, OrderSum
    from OrdersTakeaways OT
        inner join Orders O on OT.TakeawaysID = O.TakeawayID
        inner join Clients C on O.ClientID = C.ClientID
        inner join IndividualClient IC on C.ClientID = IC.ClientID
        inner join Person P on IC.PersonID = P.PersonID
        inner join Address A on C.AddressID = A.AddressID
        inner join Cities C2 on A.CityID = C2.CityID
    where (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)))
go
-- takeaways orders  Individuals--


-- takeaways orders companies --

create view dbo.[takeaways orders companies] as
    select PrefDate as [Data odbioru], CompanyName, NIP, isnull(KRS, 'Brak') as [KRS], isnull(Regon, 'Brak') as [Regon],
           Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode,
            OrderID, OrderDate, OrderCompletionDate, OrderStatus, OrderSum
    from OrdersTakeaways OT
        inner join Orders O on OT.TakeawaysID = O.TakeawayID
        inner join Clients C on O.ClientID = C.ClientID
        inner join Companies CO on C.ClientID = CO.ClientID
        inner join Address A on C.AddressID = A.AddressID
        inner join Cities C2 on A.CityID = C2.CityID
    where (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)))
go

-- takeaways orders companies --

-- ReservationInfo --

CREATE VIEW ReservationInfo AS
    SELECT R.ReservationID, TableID, StartDate, EndDate
    FROM Reservation R
        LEFT OUTER JOIN ReservationDetails RD on RD.ReservationID = R.ReservationID
    WHERE Status NOT LIKE 'Cancelled'
go

-- ReservationInfo --

-- PendingReservation --

CREATE VIEW dbo.PendingReservations AS
    SELECT R.ReservationID, startDate, endDate,
           OrderID, OrderSum
    FROM Reservation R
        inner join Orders O on R.ReservationID = O.ReservationID
    WHERE Status LIKE 'Pending'
go


-- PendingReservation --

-- PendingReservation Companies--

CREATE VIEW dbo.PendingReservationsCompanies AS
    SELECT R.ReservationID, startDate, endDate,
           OrderID, OrderSum
    FROM Reservation R
        inner join ReservationCompany RC on RC.ReservationID = R.ReservationID
        inner join Orders O on R.ReservationID = O.ReservationID
    WHERE Status LIKE 'Pending'
go

-- PendingReservation Companies--

-- PendingReservation Individual--

CREATE VIEW dbo.PendingReservationsIndividual AS
    SELECT R.ReservationID, startDate, endDate,
           OrderID, OrderSum
    FROM Reservation R
        inner join ReservationIndividual RC on RC.ReservationID = R.ReservationID
        inner join Orders O on R.ReservationID = O.ReservationID
    WHERE Status LIKE 'Pending'
go

-- Reservation accepted by --
create view dbo.ReservationAcceptedBy as
    select concat(LastName, ' ',FirstName) as Dane, Position, Email, Phone
    from Staff
        inner join Reservation R2 on Staff.StaffID = R2.StaffID
    where Status like 'accepted'
go
-- Reservation accepted by --

-- Reservation summary --

create view dbo.ReservationSummary as
    select
        O.ClientID as 'Numer clienta',
        startDate,
        endDate,
        convert(TIME,endDate - startDate , 108) as 'Czas trwania',
        O.OrderSum,
        O.OrderDate,
        O.OrderCompletionDate,
        OD.Quantity,
        RD.TableID
    from Reservation
        inner join Orders O on Reservation.ReservationID = O.ReservationID
        inner join OrderDetails OD on O.OrderID = OD.OrderID
        inner join ReservationCompany RC on Reservation.ReservationID = RC.ReservationID
        inner join ReservationDetails RD on RC.ReservationID = RD.ReservationID
    where Reservation.Status not like 'denied'
union
    select
        O.ClientID as 'Numer clienta',
        startDate,
        endDate,
        convert(TIME,endDate - startDate , 108) as 'Czas trwania',
        O.OrderSum,
        O.OrderDate,
        O.OrderCompletionDate,
        OD.Quantity,
        RD.TableID
    from Reservation
        inner join Orders O on Reservation.ReservationID = O.ReservationID
        inner join OrderDetails OD on O.OrderID = OD.OrderID
        inner join ReservationIndividual RC on Reservation.ReservationID = RC.ReservationID
        inner join ReservationDetails RD on RC.ReservationID = RD.ReservationID
    where Reservation.Status not like 'denied'
go

-- Reservation summary --

-- Products summary Daily --

create view dbo.ProductsSummaryDaily as
    select P.Name, P.Description, cast(O.OrderDate as DATE) as 'Dzien', count(OD.ProductID) as 'Liczba zamowionych produktow'
    from Products P
        inner join OrderDetails OD on P.ProductID = OD.ProductID
        inner join Orders O on OD.OrderID = O.OrderID
    where O.OrderStatus not like 'denied'
        group by P.Name, P.Description, cast(O.OrderDate as DATE)
go
-- Products summary Daily --

-- Products summary  weekly --

create view dbo.ProductsSummaryWeekly as
    select P.Name, P.Description, DATEPART(iso_week ,cast(O.OrderDate as DATE)) as 'Tydzien', DATEPART(YEAR, cast(O.OrderDate as DATE)) as 'Rok', count(OD.ProductID) as 'Liczba produktow'
    from Products P
        inner join OrderDetails OD on P.ProductID = OD.ProductID
        inner join Orders O on OD.OrderID = O.OrderID
    where O.OrderStatus not like 'denied'
        group by P.Name, P.Description, DATEPART(iso_week  ,cast(O.OrderDate as DATE)), DATEPART(YEAR, cast(O.OrderDate as DATE))
go

-- Products summary  weekly --

-- Products summary Monthly --

create view dbo.ProductsSummaryMonthly as
    select P.Name, P.Description, DATEPART(MONTH ,cast(O.OrderDate as DATE)) as 'Miesiac', DATEPART(YEAR, cast(O.OrderDate as DATE)) as 'Rok', count(OD.ProductID) as  'Liczba zamowionych produktow'
    from Products P
        inner join OrderDetails OD on P.ProductID = OD.ProductID
        inner join Orders O on OD.OrderID = O.OrderID
    where O.OrderStatus not like 'denied'
        group by P.Name, P.Description, DATEPART(MONTH ,cast(O.OrderDate as DATE)), DATEPART(YEAR, cast(O.OrderDate as DATE))
go

-- Products summary Monthly --

-- Products informations --


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

create view dbo.ProductsInformations as
    select Name, P.Description, CategoryName, iif(IsAvailable = 1, 'Aktywne', 'Nieaktywne') as 'Czy produkt aktywny',
           IIF(P.ProductID in (select ProductID
                            from Menu
                            where ((startDate >= getdate()) and (endDate >= getdate()))
                                or ((startDate >= getdate()) and endDate is null) and P.ProductID = Menu.ProductID),
               'Aktualnie w menu', 'Nie jest w menu') as 'Czy jest aktualnie w menu', count(OD.ProductID) as 'Ilosc zamowien danego produktu'
   from Products P
        inner join Category C on C.CategoryID = P.CategoryID
        inner join OrderDetails OD on P.ProductID = OD.ProductID
    group by Name, P.Description, CategoryName, P.ProductID, IsAvailable
go
-- Products informations --

