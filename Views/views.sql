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