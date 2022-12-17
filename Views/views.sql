-- Current menu view --

create view dbo.CurrentMenu as
    select MenuID, Price, Name, Description from Menu inner join Products P on P.ProductID = Menu.ProductID
    where ((getdate() >= startDate) and (getdate() <= endDate)) or ((getdate() >= startDate) and endDate is null) ;
go
-- Current menu view --


-- Current reservation vars --

create view dbo.CurrentReservationVars as
    select WZ as [Minimalna liczba zamowien], WK as [Minimalna kwota dla zamowienia], startDate, isnull(endDate, 'Brak daty konca') from ReservationVar
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
    where ((InvoiceDate >= getdate()) and (getdate() <= DueDate ) and PaymentStatusName like 'Unpaid');
go
-- unpaid invoices  Individuals--

-- unpaid invoices  Company--

create view dbo.unPaidInvoicesIndividuals as
    select  InvoiceNumber as [Numer faktury], InvoiceDate as [Data wystawienia],
            DueDate as [Data terminu zaplaty], CompanyName, NIP, isnull(KRS, 'Brak') as [KRS], isnull(Regon, 'Brak') as [Regon],
            Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode
    from Invoice
        inner join Clients C on C.ClientID = Invoice.ClientID
        inner join Companies CO on CO.ClientID = C.ClientID
        inner join Address A on C.AddressID = A.AddressID
        inner join Cities C2 on C2.CityID = A.CityID
        inner join PaymentStatus PS on Invoice.PaymentStatusID = PS.PaymentStatusID
    where ((InvoiceDate >= getdate()) and (getdate() <= DueDate ) and PaymentStatusName like 'Unpaid');
go
-- unpaid invoices  Company--

-- withdrawn products --

create view dbo.withdrawnFoods as
    select Name, P.Description, C.CategoryName from Products P
        inner join Category C on C.CategoryID = P.CategoryID where P.IsAvailable = 0
go
-- withdrawn products --

-- active products --

create view dbo.withdrawnFoods as
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
    select TableID, ChairAmount from Tables
        left join ReservationDetails RD on Tables.TableID = RD.TableID
        inner join ReservationCompany RC on RC.ReservationID = RD.ReservationID
        inner join Reservation R2 on RC.ReservationID = R2.ReservationID
    where RD.ReservationID is null and (getdate() >= startDate) and (getdate() <= endDate)

    union

    select TableID, ChairAmount from Tables
        left join ReservationDetails RD on Tables.TableID = RD.TableID
        inner join ReservationIndividual RI on RI.ReservationID = RD.ReservationID
        inner join Reservation R3 on RD.ReservationID = R3.ReservationID
    where RD.ReservationID is null and (getdate() >= startDate) and (getdate() <= endDate)
go
-- Not reserved Tables --

-- weekly raport about tables --

CREATE VIEW dbo.TablesWeekly AS
    SELECT YEAR(R2.StartDate) as year,
        DATEPART(week, R2.StartDate) as week,
        T.TableID as table_id,
        T.ChairAmount as table_size,
        COUNT(RD.TableID) as how_many_times_reserved
    FROM Tables T
        INNER JOIN ReservationDetails RD on T.TableID = RD.TableID
        INNER JOIN Reservation R2 on RD.ReservationID = R2.ReservationID
    GROUP BY YEAR(R2.StartDate), DATEPART(week, R2.StartDate), T.TableID, T.ChairAmount
go
-- weekly raport about tables --

-- monthly raport about tables --

CREATE VIEW TablesMonthly AS
    SELECT YEAR(R2.StartDate) as year,
        MONTH(R2.StartDate) as month,
        T.TableID as table_id,
        T.ChairAmount as table_size,
        COUNT(RD.TableID) as how_many_times_reserved
    FROM Tables T
        INNER JOIN ReservationDetails RD on T.TableID = RD.TableID
        INNER JOIN Reservation R2 on RD.ReservationID = R2.ReservationID
    GROUP BY YEAR(R2.StartDate), MONTH(R2.StartDate), T.TableID, T.ChairAmount
go

-- monthly raport about tables --

-- takeaway orders not picked Individuals--

create view dbo.[takeaways orders not picked Individuals] as
    select PrefDate as [Data odbioru], concat(LastName, ' ',FirstName) as [Dane],
           Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode
        from OrdersTakeaways OT
            inner join Orders O on OT.TakeawaysID = O.TakeawayID
            inner join Clients C on O.ClientID = C.ClientID
            inner join IndividualClient IC on C.ClientID = IC.ClientID
            inner join Person P on IC.PersonID = P.PersonID
            inner join Address A on C.AddressID = A.AddressID
            inner join Cities C2 on A.CityID = C2.CityID
        where OrderStatus not like 'Picked' and OrderStatus not like 'Denied' and (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or OrderCompletionDate is null)
go
-- takeaways orders not picked Individuals--

-- takeaways orders not picked Companies--

create view dbo.[takeaways orders not picked Individuals] as
    select PrefDate as [Data odbioru], CompanyName, NIP, isnull(KRS, 'Brak') as [KRS], isnull(Regon, 'Brak') as [Regon],
           Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode
           from OrdersTakeaways OT
        inner join Orders O on OT.TakeawaysID = O.TakeawayID
        inner join Clients C on O.ClientID = C.ClientID
        inner join Companies CO on C.ClientID = CO.ClientID
        inner join Address A on C.AddressID = A.AddressID
        inner join Cities C2 on A.CityID = C2.CityID
        where OrderStatus not like 'Picked' and OrderStatus not like 'Denied' and (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or OrderCompletionDate is null)
go
-- takeaways orders not picked Companies--


-- takeaway orders  Individuals--

create view dbo.[takeaways orders Individuals] as
    select PrefDate as [Data odbioru], concat(LastName, ' ',FirstName) as [Dane],
           Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode
    from OrdersTakeaways OT
        inner join Orders O on OT.TakeawaysID = O.TakeawayID
        inner join Clients C on O.ClientID = C.ClientID
        inner join IndividualClient IC on C.ClientID = IC.ClientID
        inner join Person P on IC.PersonID = P.PersonID
        inner join Address A on C.AddressID = A.AddressID
        inner join Cities C2 on A.CityID = C2.CityID
    where  (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or OrderCompletionDate is null)
go
-- takeaways orders  Individuals--


-- takeaways orders companies --

create view dbo.[takeaways orders companies] as
    select PrefDate as [Data odbioru], CompanyName, NIP, isnull(KRS, 'Brak') as [KRS], isnull(Regon, 'Brak') as [Regon],
           Phone, Email, concat(CityName, ' ',street,' ', LocalNr) as [Adres], PostalCode
    from OrdersTakeaways OT
        inner join Orders O on OT.TakeawaysID = O.TakeawayID
        inner join Clients C on O.ClientID = C.ClientID
        inner join Companies CO on C.ClientID = CO.ClientID
        inner join Address A on C.AddressID = A.AddressID
        inner join Cities C2 on A.CityID = C2.CityID
    where (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or OrderCompletionDate is null)
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

CREATE VIEW PendingReservations AS
    SELECT ReservationID, startDate, endDate
    FROM Reservation
    WHERE Status LIKE 'Pending'
go


-- PendingReservation --

