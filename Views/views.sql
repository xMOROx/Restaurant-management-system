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

--###############################################--###############################################--###############################################--###############################################

--Orders report (wyświetlanie ilości zamówień oraz ich wartości w okresach czasowych)
CREATE VIEW dbo.ordersReport AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(week, O.OrderDate) AS [Tydzień],
        COUNT(O.OrderID) AS [Ilość zamówień]
        SUM(O.OrderSum) AS [Suma przychodów]
    FROM Orders AS O
    GROUP BY ROLLUP (YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(week, O.OrderDate))
GO
--Orders report

--individual clients expenses report (wyświetlanie wydanych kwot przez klientów indywidualnych w okresach czasowych)
CREATE VIEW dbo.individualClientExpensesReport AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(week, O.OrderDate) AS [Tydzień],
        C.ClientID,
        CONCAT(P2.LastName, ' ',P2.FirstName) as [Dane],
        C.Phone,
        C.Email,
        concat(A.CityName, ' ',A.street,' ', A.LocalNr) as [Adres],
        A.PostalCode
        SUM(O.OrderSum) AS [wydane środki]
    FROM Orders AS O
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P2 ON P2.PersonID = IC.PersonID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
    GROUP BY GROUPING SET (
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(week, O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate))
        )
GO
--individualClients expenses report

--company expenses report (wyświetlanie wydanych kwot przez firmy w okresach czasowych)
CREATE VIEW dbo.companyExpensesReport AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(week, O.OrderDate) AS [Tydzień],
        C.ClientID,
        C2.CompanyName,
        C2.NIP,
        ISNULL(C2.KRS, 'Brak') as [KRS],
        ISNULL(C2.Regon, 'Brak') as [Regon],
        C.Phone,
        C.Email,
        CONCAT(A.CityName, ' ',A.street,' ', A.LocalNr) as [Adres],
        A.PostalCode,
        SUM(O.OrderSum) AS [wydane środki]
    FROM Orders AS O
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
    GROUP BY GROUPING SET (
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(week, O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate))
        )
GO
--company expenses report

--Number of individual clients (ilość klientów indywidualnych w okresach czasu)
CREATE VIEW dbo.numberOfIndividualClients AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(week, O.OrderDate) AS [Tydzień],
        COUNT(C.CustomerID) AS [Ilość klientów indywidualnych]
    FROM Orders AS O
    INNER JOIN Client C ON C.OrderID = O.OrderID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    GROUP BY GROUPING SET (
            (YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(week, O.OrderDate)),
            (YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (YEAR(O.OrderDate))
        )
GO
--Number of clients

--Number of companies (ilość firm w okresach czasu)
CREATE VIEW dbo.numberOfCompanies AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(week, O.OrderDate) AS [Tydzień],
        COUNT(C.CustomerID) AS [Ilość zamawiających firm]
    FROM Orders AS O
    INNER JOIN Client C ON C.OrderID = O.OrderID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    GROUP BY GROUPING SET (
            (YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(week, O.OrderDate)),
            (YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (YEAR(O.OrderDate))
        )
GO
--Number of companies

--Number of orders individual client       (ilość zamówień złożonych przez klientów indywidualnych w okresach czasu)
CREATE VIEW dbo.individualClientNumberOfOrders AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(week, O.OrderDate) AS [Tydzień],
        C.ClientID,
        CONCAT(P2.LastName, ' ',P2.FirstName) as [Dane],
        C.Phone,
        C.Email,
        concat(A.CityName, ' ',A.street,' ', A.LocalNr) as [Adres],
        A.PostalCode
        COUNT(DISTINCT O.OrderID) AS [Ilość złożonych zamówień]
    FROM Orders AS O
    INNER JOIN Client C ON C.OrderID = O.OrderID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P2 ON P2.PersonID = IC.PersonID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
    GROUP BY GROUPING SET (
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(week, O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate))
        )
GO
--Number of orders individual client

--Number of orders companies       (ilość zamówień złożonych przez firmy w okresach czasu)
CREATE VIEW dbo.companiesNumberOfOrders AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(week, O.OrderDate) AS [Tydzień],
        C.ClientID,
        C2.CompanyName,
        C2.NIP,
        ISNULL(C2.KRS, 'Brak') as [KRS],
        ISNULL(C2.Regon, 'Brak') as [Regon],
        C.Phone,
        C.Email,
        CONCAT(A.CityName, ' ',A.street,' ', A.LocalNr) as [Adres],
        A.PostalCode,
        COUNT(DISTINCT O.OrderID) AS [Ilość złożonych zamówień]
    FROM Orders AS O
    INNER JOIN Client C ON C.OrderID = O.OrderID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
    GROUP BY GROUPING SET (
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(week, O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate))
        )
GO
--Number of orders companies

--individual clients who have not paid for their orders (klienci indywidualni, którzy mają nieopłacone zamówienia oraz jaka jest ich należność)
CREATE VIEW dbo.individualClientsWhoNotPayForOrders AS
    SELECT
        C.ClientID,
        CONCAT(P.LastName, ' ',P.FirstName) as [Dane],
        C.Phone,
        C.Email,
        concat(A.CityName, ' ',A.street,' ', A.LocalNr) as [Adres],
        A.PostalCode,
        C.OrderDate,
        SUM(O.OrderSum) AS [Zaległa należność]
    FROM Clients AS C
    WHERE (PS.PaymentStatusName LIKE [nieopłacone])
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P ON P.PersonID = IndividualClient.PersonID
    INNER JOIN Orders O ON O.ClientID = C.ClientID
    INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
    GROUP BY C.ClientID
GO
--individual clients who have not paid for their orders



--companies who have not paid for their orders  (firmy, które mają nieopłacone zamówienia oraz jaka jest ich wartość)
CREATE VIEW dbo.companiesWhoNotPayForOrders AS
    SELECT
        C.ClientID,
        C2.CompanyName,
        C2.NIP,
        ISNULL(C2.KRS, 'Brak') as [KRS],
        ISNULL(C2.Regon, 'Brak') as [Regon],
        C.Phone,
        C.Email,
        CONCAT(A.CityName, ' ',A.street,' ', A.LocalNr) as [Adres],
        A.PostalCode,
        SUM(O.OrderSum) AS [Zaległa należność]
    FROM Clients AS C
    WHERE (PS.PaymentStatusName LIKE [nieopłacone])
    INNER JOIN Orders O ON O.ClientID = C.ClientID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
    GROUP BY C.ClientID
GO
--companies who have not paid for their orders

--orders in progress              (zamówienia na miejscu, które są przygotowywane)
CREATE VIEW dbo.ordersInProgress AS
    SELECT
        O.OrderID,
        O.ClientID,
        C.Phone,
        C.Email,
        OD.Quantity,
        P.Name
    FROM Orders
    INNER JOIN Clients C ON C.OrderID = O.OrderID
    INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    INNER JOIN Products P ON P.ProductID = OD.ProductID
    WHERE (O.TakeawayID IS NULL) AND (O.OrderStatus LIKE 'accepted')
GO
--orders in progress

--takeaway orders in progress      (zamówienia na wynos, które są przygotowywane)
CREATE VIEW dbo.takeawayOrdersInProgress AS
    SELECT
        O.OrderID,
        O.ClientID,
        C.Phone,
        C.Email,
        OD.Quantity,
        P.Name,
        OT.PrefDate
    FROM Orders
    INNER JOIN Clients C ON C.OrderID = O.OrderID
    INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    INNER JOIN Products P ON P.ProductID = OD.ProductID
    INNER JOIN OrdersTakeaway OT ON OT.TakeawayID = O.TakeawayID
    WHERE (O.TakeawayID IS NOT NULL) AND (O.OrderStatus LIKE 'accepted')
GO
--takeaway orders in progress

--orders for individual clients information - (infromacje o zamówieniach dla klientów indywidualnych)
CREATE VIEW dbo.ordersInformationIndividualClient AS
    SELECT
        O.OrderID,
        O.OrderStatus,
        PS.PaymentStatus,
        SUM(O.OrderSum) AS [Wartość zamówienia],
        C.Phone,
        C.Email,
        CONCAT(P.LastName, ' ',P.FirstName) as [Dane],
        CONCAT(A.CityName, ' ',A.street,' ', A.LocalNr) as [Adres],
        A.PostalCode,
    FROM Orders AS O
    INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P ON P.PersonID = P.IndividualClient
    INNER JOIN Adress A ON A.AdressID = C.AdressID
    INNER JOIN
    GROUP BY O.OrderID
GO
--orders for individual clients information

--orders for company information - (informacje o zamówieniach dla firm)
CREATE VIEW dbo.ordersInformationCompany AS
    SELECT
        O.OrderID,
        O.OrderStatus,
        PS.PaymentStatus,
        SUM(O.OrderSum) AS [Wartość zamówienia],
        C.Phone,
        C.Email,
        C2.CompanyName,
        C2.NIP,
        ISNULL(C2.KRS, 'Brak') as [KRS],
        ISNULL(C2.Regon, 'Brak') as [Regon],
        CONCAT(A.CityName, ' ',A.street,' ', A.LocalNr) as [Adres],
        A.PostalCode,
    FROM Orders AS O
    INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
    INNER JOIN
    GROUP BY O.OrderID
GO
--orders for company information
