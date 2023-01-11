-- Current menu view --
create view dbo.CurrentMenu as
    select M1.MenuID, Price, Name, P.Description as 'Product Description', M2.Description as 'Menu Description' from MenuDetails M1
        inner join Products P on P.ProductID = M1.ProductID
        INNER JOIN Menu M2 on M1.MenuID = M2.MenuID
    where ((getdate() >= startDate) and (getdate() <= endDate)) or ((getdate() >= startDate) and endDate is null) ;
go

GO
    -- Current menu view --
    -- Current reservation vars --
    CREATE VIEW dbo.CurrentReservationVars AS
SELECT
    WZ AS [Minimalna liczba zamowien],
    WK AS [Minimalna kwota dla zamowienia],
    startDate,
    isnull(
        CONVERT(varchar(20), endDate, 120),
        'Obowiązuje zawsze'
    ) AS 'Koniec menu'
FROM
    ReservationVar
WHERE
    (
        (getdate() >= startDate)
        AND (getdate() <= endDate)
    )
    OR (
        (getdate() >= startDate)
        AND endDate IS NULL
    );

GO
    -- unpaid invoices  Individuals--
    CREATE VIEW dbo.unPaidInvoicesIndividuals AS
SELECT
    InvoiceNumber AS [Numer faktury],
    InvoiceDate AS [Data wystawienia],
    DueDate AS [Data terminu zaplaty],
    concat(LastName, ' ', FirstName) AS [Dane],
    Phone,
    Email,
    concat(CityName, ' ', street, ' ', LocalNr) AS [Adres],
    PostalCode
FROM
    Invoice
    INNER JOIN Clients C ON C.ClientID = Invoice.ClientID
    INNER JOIN Address A ON C.AddressID = A.AddressID
    INNER JOIN IndividualClient IC ON C.ClientID = IC.ClientID
    INNER JOIN Person P ON P.PersonID = IC.PersonID
    INNER JOIN Cities C2 ON C2.CityID = A.CityID
    INNER JOIN PaymentStatus PS ON Invoice.PaymentStatusID = PS.PaymentStatusID
WHERE
    PaymentStatusName LIKE 'Unpaid';

-- system will change status
GO
    -- unpaid invoices  Individuals--
    -- unpaid invoices  Company--
    CREATE VIEW dbo.unPaidInvoicesCompanies AS
SELECT
    InvoiceNumber AS [Numer faktury],
    InvoiceDate AS [Data wystawienia],
    DueDate AS [Data terminu zaplaty],
    CompanyName,
    NIP,
    isnull(KRS, 'Brak') AS [KRS],
    isnull(Regon, 'Brak') AS [Regon],
    Phone,
    Email,
    concat(CityName, ' ', street, ' ', LocalNr) AS [Adres],
    PostalCode
FROM
    Invoice
    INNER JOIN Clients C ON C.ClientID = Invoice.ClientID
    INNER JOIN Companies CO ON CO.ClientID = C.ClientID
    INNER JOIN Address A ON C.AddressID = A.AddressID
    INNER JOIN Cities C2 ON C2.CityID = A.CityID
    INNER JOIN PaymentStatus PS ON Invoice.PaymentStatusID = PS.PaymentStatusID
WHERE
    (PaymentStatusName LIKE 'Unpaid');

GO
    -- unpaid invoices  Company--
    -- withdrawn products --
    CREATE VIEW dbo.withdrawnProducts AS
SELECT
    Name,
    P.Description,
    C.CategoryName
FROM
    Products P
    INNER JOIN Category C ON C.CategoryID = P.CategoryID
WHERE
    P.IsAvailable = 0
GO
    -- withdrawn products --
    -- active products --
    CREATE VIEW dbo.ActiveProducts AS
SELECT
    Name,
    P.Description,
    C.CategoryName
FROM
    Products P
    INNER JOIN Category C ON C.CategoryID = P.CategoryID
WHERE
    P.IsAvailable = 1
GO
    -- active products --
    -- Active Tables --
    -- dostępne dla klientów --
    CREATE VIEW dbo.ActiveTables AS
SELECT
    TableID,
    ChairAmount
FROM
    TABLES
WHERE
    isActive = 1
GO
    -- Active Tables --
    -- Not reserved Tables --
    CREATE VIEW dbo.[Not reserved Tables] AS
SELECT
    TableID,
    ChairAmount
FROM
    TABLES
WHERE
    TableID NOT IN(
        SELECT
            ReservationDetails.TableID
        FROM
            ReservationDetails
            INNER JOIN ReservationCompany RC ON RC.ReservationID = ReservationDetails.ReservationID
            INNER JOIN Reservation R2 ON RC.ReservationID = R2.ReservationID
        WHERE
            (getdate() >= startDate)
            AND (getdate() <= endDate)
            AND (
                STATUS NOT LIKE 'cancelled'
                AND STATUS NOT LIKE 'denied'
            )
            AND isActive = 1
    )
UNION
SELECT
    TableID,
    ChairAmount
FROM
    TABLES
WHERE
    TableID NOT IN(
        SELECT
            ReservationDetails.TableID
        FROM
            ReservationDetails
            INNER JOIN ReservationIndividual RC ON RC.ReservationID = ReservationDetails.ReservationID
            INNER JOIN Reservation R2 ON RC.ReservationID = R2.ReservationID
        WHERE
            (getdate() >= startDate)
            AND (getdate() <= endDate)
            AND (
                STATUS NOT LIKE 'cancelled'
                AND STATUS NOT LIKE 'denied'
            )
            AND isActive = 1
    )
GO
    -- Not reserved Tables --
    -- weekly raport about tables --
    CREATE VIEW dbo.TablesWeekly AS
SELECT
    YEAR(R2.StartDate) AS year,
    DATEPART(iso_week, R2.StartDate) AS week,
    T.TableID AS table_id,
    T.ChairAmount AS table_size,
    COUNT(RD.TableID) AS how_many_times_reserved
FROM
    TABLES T
    INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
    INNER JOIN ReservationIndividual RI ON RI.ReservationID = RD.ReservationID
    INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
WHERE
    (
        STATUS NOT LIKE 'cancelled'
        AND STATUS NOT LIKE 'denied'
    )
GROUP BY
    YEAR(R2.StartDate),
    DATEPART(iso_week, R2.StartDate),
    T.TableID,
    T.ChairAmount
UNION
SELECT
    YEAR(R2.StartDate) AS year,
    DATEPART(iso_week, R2.StartDate) AS week,
    T.TableID AS table_id,
    T.ChairAmount AS table_size,
    COUNT(RD.TableID) AS how_many_times_reserved
FROM
    TABLES T
    INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
    INNER JOIN ReservationCompany RI ON RI.ReservationID = RD.ReservationID
    INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
WHERE
    (
        STATUS NOT LIKE 'cancelled'
        AND STATUS NOT LIKE 'denied'
    )
GROUP BY
    YEAR(R2.StartDate),
    DATEPART(iso_week, R2.StartDate),
    T.TableID,
    T.ChairAmount
GO
    -- weekly raport about tables --
    -- monthly raport about tables --
    CREATE VIEW dbo.TablesMonthly AS
SELECT
    YEAR(R2.StartDate) AS year,
    DATEPART(MONTH, R2.StartDate) AS MONTH,
    T.TableID AS table_id,
    T.ChairAmount AS table_size,
    COUNT(RD.TableID) AS how_many_times_reserved
FROM
    TABLES T
    INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
    INNER JOIN ReservationIndividual RI ON RI.ReservationID = RD.ReservationID
    INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
WHERE
    (
        STATUS NOT LIKE 'cancelled'
        AND STATUS NOT LIKE 'denied'
    )
GROUP BY
    YEAR(R2.StartDate),
    DATEPART(MONTH, R2.StartDate),
    T.TableID,
    T.ChairAmount
UNION
SELECT
    YEAR(R2.StartDate) AS year,
    DATEPART(MONTH, R2.StartDate) AS MONTH,
    T.TableID AS table_id,
    T.ChairAmount AS table_size,
    COUNT(RD.TableID) AS how_many_times_reserved
FROM
    TABLES T
    INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
    INNER JOIN ReservationCompany RI ON RI.ReservationID = RD.ReservationID
    INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
WHERE
    (
        STATUS NOT LIKE 'cancelled'
        AND STATUS NOT LIKE 'denied'
    )
GROUP BY
    YEAR(R2.StartDate),
    DATEPART(MONTH, R2.StartDate),
    T.TableID,
    T.ChairAmount
GO
    -- monthly raport about tables --
    -- takeaway orders not picked Individuals--
    CREATE VIEW dbo.[takeaways orders not picked Individuals] AS
SELECT
    PrefDate AS [Data odbioru],
    concat(LastName, ' ', FirstName) AS [Dane],
    Phone,
    Email,
    concat(CityName, ' ', street, ' ', LocalNr) AS [Adres],
    PostalCode,
    OrderID,
    OrderDate,
    OrderCompletionDate,
    OrderSum
FROM
    OrdersTakeaways OT
    INNER JOIN Orders O ON OT.TakeawaysID = O.TakeawayID
    INNER JOIN Clients C ON O.ClientID = C.ClientID
    INNER JOIN IndividualClient IC ON C.ClientID = IC.ClientID
    INNER JOIN Person P ON IC.PersonID = P.PersonID
    INNER JOIN Address A ON C.AddressID = A.AddressID
    INNER JOIN Cities C2 ON A.CityID = C2.CityID
WHERE
    OrderStatus LIKE 'Completed'
GO
    -- takeaways orders not picked Individuals--
    -- takeaways orders not picked Companies--
    CREATE VIEW dbo.[takeaways orders not picked Companies] AS
SELECT
    PrefDate AS [Data odbioru],
    CompanyName,
    NIP,
    isnull(KRS, 'Brak') AS [KRS],
    isnull(Regon, 'Brak') AS [Regon],
    Phone,
    Email,
    concat(CityName, ' ', street, ' ', LocalNr) AS [Adres],
    PostalCode,
    OrderID,
    OrderDate,
    OrderCompletionDate,
    OrderSum
FROM
    OrdersTakeaways OT
    INNER JOIN Orders O ON OT.TakeawaysID = O.TakeawayID
    INNER JOIN Clients C ON O.ClientID = C.ClientID
    INNER JOIN Companies CO ON C.ClientID = CO.ClientID
    INNER JOIN Address A ON C.AddressID = A.AddressID
    INNER JOIN Cities C2 ON A.CityID = C2.CityID
WHERE
    OrderStatus LIKE 'Completed'
GO
    -- takeaways orders not picked Companies--
    -- takeaway orders  Individuals--
    CREATE VIEW dbo.[takeaways orders Individuals] AS
SELECT
    PrefDate AS [Data odbioru],
    concat(LastName, ' ', FirstName) AS [Dane],
    Phone,
    Email,
    concat(CityName, ' ', street, ' ', LocalNr) AS [Adres],
    PostalCode,
    OrderID,
    OrderDate,
    OrderCompletionDate,
    OrderStatus,
    OrderSum
FROM
    OrdersTakeaways OT
    INNER JOIN Orders O ON OT.TakeawaysID = O.TakeawayID
    INNER JOIN Clients C ON O.ClientID = C.ClientID
    INNER JOIN IndividualClient IC ON C.ClientID = IC.ClientID
    INNER JOIN Person P ON IC.PersonID = P.PersonID
    INNER JOIN Address A ON C.AddressID = A.AddressID
    INNER JOIN Cities C2 ON A.CityID = C2.CityID
WHERE
    (
        (
            (getdate() >= OrderDate)
            AND (getdate() <= OrderCompletionDate)
        )
        OR (
            OrderCompletionDate IS NULL
            AND (getdate() >= OrderDate)
        )
    )
GO
    -- takeaways orders  Individuals--
    -- takeaways orders companies --
    CREATE VIEW dbo.[takeaways orders companies] AS
SELECT
    PrefDate AS [Data odbioru],
    CompanyName,
    NIP,
    isnull(KRS, 'Brak') AS [KRS],
    isnull(Regon, 'Brak') AS [Regon],
    Phone,
    Email,
    concat(CityName, ' ', street, ' ', LocalNr) AS [Adres],
    PostalCode,
    OrderID,
    OrderDate,
    OrderCompletionDate,
    OrderStatus,
    OrderSum
FROM
    OrdersTakeaways OT
    INNER JOIN Orders O ON OT.TakeawaysID = O.TakeawayID
    INNER JOIN Clients C ON O.ClientID = C.ClientID
    INNER JOIN Companies CO ON C.ClientID = CO.ClientID
    INNER JOIN Address A ON C.AddressID = A.AddressID
    INNER JOIN Cities C2 ON A.CityID = C2.CityID
WHERE
    (
        (
            (getdate() >= OrderDate)
            AND (getdate() <= OrderCompletionDate)
        )
        OR (
            OrderCompletionDate IS NULL
            AND (getdate() >= OrderDate)
        )
    )
GO
    -- takeaways orders companies --
    -- ReservationInfo --
    CREATE VIEW ReservationInfo AS
SELECT
    R.ReservationID,
    TableID,
    StartDate,
    EndDate
FROM
    Reservation R
    LEFT OUTER JOIN ReservationDetails RD ON RD.ReservationID = R.ReservationID
WHERE
    STATUS NOT LIKE 'Cancelled'
GO
    -- ReservationInfo --
    -- ReservationDenied --
    CREATE VIEW ReservationDenied AS
SELECT
    R.ReservationID,
    TableID,
    ClientID,
    StartDate,
    EndDate
FROM
    Reservation R
    LEFT OUTER JOIN ReservationDetails RD ON RD.ReservationID = R.ReservationID
    INNER JOIN Orders O ON O.ReservationID = R.ReservationID
WHERE
    STATUS LIKE 'denied'
GO
    -- ReservationDenied --
    -- PendingReservation --
    CREATE VIEW dbo.PendingReservations AS
SELECT
    R.ReservationID,
    startDate,
    endDate,
    OrderID,
    OrderSum
FROM
    Reservation R
    INNER JOIN Orders O ON R.ReservationID = O.ReservationID
WHERE
    STATUS LIKE 'Pending'
GO
    -- PendingReservation --
    --Orders report (wyświetlanie ilości zamówień oraz ich wartości w okresach czasowych)
CREATE VIEW dbo.ordersReport AS
    SELECT
        isnull(convert(varchar(50), YEAR(O.OrderDate), 120), 'Podsumowanie po latach') AS [Year],
        isnull(convert(varchar(50),  MONTH(O.OrderDate), 120), 'Podsumowanie po miesiacach') AS [Month],
        isnull(convert(varchar(50),  DATEPART(iso_week , O.OrderDate), 120), 'Podsumowanie po tygodniach') AS [WEEK],
        COUNT(O.OrderID) AS [ilość zamówień],
        SUM(OD.Quantity * M.Price) AS [suma przychodów]
    FROM Orders AS O
    INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    INNER JOIN Products P ON P.ProductID = OD.ProductID
    INNER JOIN MenuDetails M ON M.ProductID = P.ProductID
    GROUP BY ROLLUP (YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(iso_week, O.OrderDate))
GO
    --Orders report
    --individual clients expenses report (wyświetlanie wydanych kwot przez klientów indywidualnych w okresach czasowych)
    CREATE VIEW dbo.individualClientExpensesReport AS
SELECT
    YEAR(O.OrderDate) AS [Year],
    isnull(
        CONVERT(varchar(50), MONTH(O.OrderDate), 120),
        'Podsumowanie miesiaca'
    ) AS [Month],
    isnull(
        CONVERT(
            varchar(50),
            DATEPART(iso_week, O.OrderDate),
            120
        ),
        'Podsumowanie tygodnia'
    ) AS [WEEK],
    C.ClientID,
    CONCAT(P2.LastName, ' ', P2.FirstName) AS [Dane],
    C.Phone,
    C.Email,
    concat(A.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
    A.PostalCode SUM(O.OrderSum) AS [wydane środki]
FROM
    Orders AS O
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P2 ON P2.PersonID = IC.PersonID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
GROUP BY
    GROUPING SETS (
        (
            C.ClientID,
            YEAR(O.OrderDate),
            MONTH(O.OrderDate),
            DATEPART(week, O.OrderDate)
        ),
        (
            C.ClientID,
            YEAR(O.OrderDate),
            MONTH(O.OrderDate)
        ),
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
    ISNULL(cast(C2.KRS AS varchar), 'Brak') AS [KRS],
    ISNULL(cast(C2.Regon AS varchar), 'Brak') AS [Regon],
    C.Phone,
    C.Email,
    CONCAT(A.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
    A.PostalCode,
    SUM(O.OrderSum) AS [wydane środki]
FROM
    Orders AS O
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
GROUP BY
    GROUPING SETS (
        (
            C.ClientID,
            YEAR(O.OrderDate),
            MONTH(O.OrderDate),
            DATEPART(week, O.OrderDate)
        ),
        (
            C.ClientID,
            YEAR(O.OrderDate),
            MONTH(O.OrderDate)
        ),
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
    COUNT(DISTINCT C.CustomerID) AS [Ilość klientów indywidualnych]
FROM
    Orders AS O
    INNER JOIN Client C ON C.OrderID = O.OrderID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
GROUP BY
    GROUPING SETS (
        (
            YEAR(O.OrderDate),
            MONTH(O.OrderDate),
            DATEPART(week, O.OrderDate)
        ),
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
    COUNT(DISTINCT C.CustomerID) AS [Ilość zamawiających firm]
FROM
    Orders AS O
    INNER JOIN Client C ON C.OrderID = O.OrderID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
GROUP BY
    GROUPING SETS (
        (
            YEAR(O.OrderDate),
            MONTH(O.OrderDate),
            DATEPART(week, O.OrderDate)
        ),
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
    CONCAT(P2.LastName, ' ', P2.FirstName) AS [Dane],
    C.Phone,
    C.Email,
    concat(A.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
    A.PostalCode COUNT(DISTINCT O.OrderID) AS [Ilość złożonych zamówień]
FROM
    Orders AS O
    INNER JOIN Client C ON C.OrderID = O.OrderID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P2 ON P2.PersonID = IC.PersonID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
GROUP BY
    GROUPING SETS (
        (
            C.ClientID,
            YEAR(O.OrderDate),
            MONTH(O.OrderDate),
            DATEPART(week, O.OrderDate)
        ),
        (
            C.ClientID,
            YEAR(O.OrderDate),
            MONTH(O.OrderDate)
        ),
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
    ISNULL(cast(C2.KRS AS varchar), 'Brak') AS [KRS],
    ISNULL(cast(C2.Regon AS varchar), 'Brak') AS [Regon],
    C.Phone,
    C.Email,
    CONCAT(A.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
    A.PostalCode,
    COUNT(DISTINCT O.OrderID) AS [Ilość złożonych zamówień]
FROM
    Orders AS O
    INNER JOIN Client C ON C.OrderID = O.OrderID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN Adress A ON A.AdressID = C.AdressID
GROUP BY
    GROUPING SETS (
        (
            C.ClientID,
            YEAR(O.OrderDate),
            MONTH(O.OrderDate),
            DATEPART(week, O.OrderDate)
        ),
        (
            C.ClientID,
            YEAR(O.OrderDate),
            MONTH(O.OrderDate)
        ),
        (C.ClientID, YEAR(O.OrderDate))
    )
GO
    --Number of orders companies
    --individual clients who have not paid for their orders (klienci indywidualni, którzy mają nieopłacone zamówienia oraz jaka jest ich należność)
    CREATE VIEW dbo.individualClientsWhoNotPayForOrders AS
SELECT
    C.ClientID,
    CONCAT(P.LastName, ' ', P.FirstName) AS [Dane],
    C.Phone,
    C.Email,
    concat(C2.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
    A.PostalCode,
    O.OrderDate,
    SUM(O.OrderSum) AS [money to pay]
FROM
    Clients AS C
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P ON P.PersonID = IC.PersonID
    INNER JOIN Orders O ON O.ClientID = C.ClientID
    INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
    INNER JOIN Address A ON A.AddressID = C.AddressID
    INNER JOIN Cities C2 ON C2.CityID = A.CityID
WHERE
    (PS.PaymentStatusName LIKE 'Unpaid')
GROUP BY
    C.ClientID,
    CONCAT(P.LastName, ' ', P.FirstName),
    C.Phone,
    C.Email,
    concat(C2.CityName, ' ', A.street, ' ', A.LocalNr),
    A.PostalCode,
    O.OrderDate
GO
    --individual clients who have not paid for their orders
    --companies who have not paid for their orders  (firmy, które mają nieopłacone zamówienia oraz jaka jest ich wartość)
    CREATE VIEW dbo.companiesWhoNotPayForOrders AS
SELECT
    C.ClientID,
    C2.CompanyName,
    C2.NIP,
    ISNULL(C2.KRS, 'Brak') AS [KRS],
    ISNULL(C2.Regon, 'Brak') AS [Regon],
    C.Phone,
    C.Email,
    CONCAT(C3.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
    A.PostalCode,
    SUM(O.OrderSum) AS [money to pay]
FROM
    Clients AS C
    INNER JOIN Orders O ON O.ClientID = C.ClientID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
    INNER JOIN Address A ON A.AddressID = C.AddressID
    INNER JOIN Cities C3 ON C3.CityID = A.CityID
WHERE
    (PS.PaymentStatusName LIKE 'Unpaid')
GROUP BY
    C.ClientID,
    C2.CompanyName,
    C2.NIP,
    ISNULL(C2.KRS, 'Brak'),
    ISNULL(C2.Regon, 'Brak'),
    C.Phone,
    C.Email,
    CONCAT(C3.CityName, ' ', A.street, ' ', A.LocalNr),
    A.PostalCode
GO
    --companies who have not paid for their orders
    --orders on-site             (zamówienia na miejscu, które są przygotowywane)
    CREATE VIEW dbo.ordersonSite AS
SELECT
    O.OrderID,
    O.ClientID,
    C.Phone,
    C.Email,
    OD.Quantity,
    P.Name
FROM
    Orders
    INNER JOIN Clients C ON C.OrderID = O.OrderID
    INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    INNER JOIN Products P ON P.ProductID = OD.ProductID
WHERE
    (O.TakeawayID IS NULL)
    AND (O.OrderStatus LIKE 'accepted')
GO
    --orders in progress
    --takeaway orders in progress      (zamówienia na wynos, które są przygotowywane dla klientów indywidualnych)
    CREATE VIEW dbo.takeawayOrdersInProgressIndividual AS
SELECT
    O.OrderID,
    O.ClientID,
    C.Phone,
    C.Email,
    concat(P.LastName, ' ', P.FirstName) AS [Dane],
    OD.Quantity,
    P.Name,
    OT.PrefDate
FROM
    Orders
    INNER JOIN Clients C ON C.OrderID = O.OrderID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P ON P.PersonID = IC.PersonID
    INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    INNER JOIN Products P ON P.ProductID = OD.ProductID
    INNER JOIN OrdersTakeaway OT ON OT.TakeawayID = O.TakeawayID
WHERE
    (O.OrderStatus LIKE 'accepted')
GO
    --takeaway orders in progress
    --takeaway orders in progress      (zamówienia na wynos, które są przygotowywane dla klientów indywidualnych)
    CREATE VIEW dbo.takeawayOrdersInProgressCompanies AS
SELECT
    O.OrderID,
    O.ClientID,
    C.Phone,
    C.Email,
    C2.CompanyName,
    C2.NIP,
    ISNULL(cast(C2.KRS AS varchar), 'Brak') AS [KRS],
    ISNULL(cast(C2.Regon AS varchar), 'Brak') AS [Regon],
    OD.Quantity,
    P.Name,
    OT.PrefDate
FROM
    Orders
    INNER JOIN Clients C ON C.OrderID = O.OrderID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    INNER JOIN Products P ON P.ProductID = OD.ProductID
    INNER JOIN OrdersTakeaway OT ON OT.TakeawayID = O.TakeawayID
WHERE
    (O.OrderStatus LIKE 'accepted')
GO
    --takeaway orders in progress
    --orders for individual clients information - (informacje o zamówieniach dla klientów indywidualnych)
    CREATE VIEW dbo.ordersInformationIndividualClient AS
SELECT
    O.OrderID,
    O.OrderStatus,
    PS.PaymentStatusName,
    SUM(O.OrderSum) AS [Wartość zamówienia],
    C.Phone,
    C.Email,
    CONCAT(P.LastName, ' ', P.FirstName) AS [Dane],
    CONCAT(C2.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
    A.PostalCode
FROM
    Orders AS O
    INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    INNER JOIN Person P ON P.PersonID = IC.PersonID
    INNER JOIN Address A ON A.AddressID = C.AddressID
    INNER JOIN Cities C2 ON A.CityID = C2.CityID
GROUP BY
    O.OrderID,
    O.OrderStatus,
    PS.PaymentStatusName,
    C.Phone,
    C.Email,
    CONCAT(P.LastName, ' ', P.FirstName),
    CONCAT(C2.CityName, ' ', A.street, ' ', A.LocalNr),
    A.PostalCode
GO
    --orders for individual clients information
    --orders for company information - (informacje o zamówieniach dla firm)
    CREATE VIEW dbo.ordersInformationCompany AS
SELECT
    O.OrderID,
    O.OrderStatus,
    PS.PaymentStatusName,
    SUM(O.OrderSum) AS [Wartość zamówienia],
    C.Phone,
    C.Email,
    C2.CompanyName,
    C2.NIP,
    ISNULL(cast(C2.KRS AS varchar), 'Brak') AS [KRS],
    ISNULL(cast(C2.Regon AS varchar), 'Brak') AS [Regon],
    CONCAT(C3.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
    A.PostalCode
FROM
    Orders AS O
    INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    INNER JOIN Address A ON A.AddressID = C.AddressID
    INNER JOIN Cities C3 ON A.CityID = C3.CityID
GROUP BY
    O.OrderID,
    O.OrderStatus,
    PS.PaymentStatusName,
    C.Phone,
    C.Email,
    C2.CompanyName,
    C2.NIP,
    ISNULL(cast(C2.KRS AS varchar), 'Brak'),
    ISNULL(cast(C2.Regon AS varchar), 'Brak'),
    CONCAT(C3.CityName, ' ', A.street, ' ', A.LocalNr),
    A.PostalCode
GO
    --orders for company information
    -- PendingReservation Companies--
    CREATE VIEW dbo.PendingReservationsCompanies AS
SELECT
    R.ReservationID,
    startDate,
    endDate,
    OrderID,
    OrderSum
FROM
    Reservation R
    INNER JOIN ReservationCompany RC ON RC.ReservationID = R.ReservationID
    INNER JOIN Orders O ON R.ReservationID = O.ReservationID
WHERE
    STATUS LIKE 'Pending'
GO
    -- PendingReservation Companies--
    -- PendingReservation Individual--
    CREATE VIEW dbo.PendingReservationsIndividual AS
SELECT
    R.ReservationID,
    startDate,
    endDate,
    OrderID,
    OrderSum
FROM
    Reservation R
    INNER JOIN ReservationIndividual RC ON RC.ReservationID = R.ReservationID
    INNER JOIN Orders O ON R.ReservationID = O.ReservationID
WHERE
    STATUS LIKE 'Pending'
GO
    -- Reservation accepted by --
    CREATE VIEW dbo.ReservationAcceptedBy AS
SELECT
    concat(LastName, ' ', FirstName) AS Dane,
    Position,
    Email,
    Phone
FROM
    Staff
    INNER JOIN Reservation R2 ON Staff.StaffID = R2.StaffID
WHERE
    STATUS LIKE 'accepted'
GO
    -- Reservation accepted by --
    -- Reservation summary --
    CREATE VIEW dbo.ReservationSummary AS
SELECT
    O.ClientID AS 'Numer clienta',
    startDate,
    endDate,
    CONVERT(TIME, endDate - startDate, 108) AS 'Czas trwania',
    O.OrderSum,
    O.OrderDate,
    O.OrderCompletionDate,
    OD.Quantity,
    RD.TableID
FROM
    Reservation
    INNER JOIN Orders O ON Reservation.ReservationID = O.ReservationID
    INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    INNER JOIN ReservationCompany RC ON Reservation.ReservationID = RC.ReservationID
    INNER JOIN ReservationDetails RD ON RC.ReservationID = RD.ReservationID
WHERE
    STATUS NOT LIKE 'denied'
UNION
SELECT
    O.ClientID AS 'Numer clienta',
    startDate,
    endDate,
    CONVERT(TIME, endDate - startDate, 108) AS 'Czas trwania',
    O.OrderSum,
    O.OrderDate,
    O.OrderCompletionDate,
    OD.Quantity,
    RD.TableID
FROM
    Reservation
    INNER JOIN Orders O ON Reservation.ReservationID = O.ReservationID
    INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    INNER JOIN ReservationIndividual RC ON Reservation.ReservationID = RC.ReservationID
    INNER JOIN ReservationDetails RD ON RC.ReservationID = RD.ReservationID
WHERE
    STATUS NOT LIKE 'denied'
GO
    -- Reservation summary --
    -- Products summary Daily --
    CREATE VIEW dbo.ProductsSummaryDaily AS
SELECT
    P.Name,
    P.Description,
    cast(O.OrderDate AS DATE) AS 'Dzien',
    count(OD.ProductID) AS 'Liczba zamowionych produktow'
FROM
    Products P
    INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID
    INNER JOIN Orders O ON OD.OrderID = O.OrderID
WHERE
    O.OrderStatus NOT LIKE 'denied'
GROUP BY
    P.Name,
    P.Description,
    cast(O.OrderDate AS DATE)
GO
    -- Products summary Daily --
    -- Products summary  weekly --
    CREATE VIEW dbo.ProductsSummaryWeekly AS
SELECT
    P.Name,
    P.Description,
    DATEPART(iso_week, cast(O.OrderDate AS DATE)) AS 'Tydzien',
    DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
    count(OD.ProductID) AS 'Liczba produktow'
FROM
    Products P
    INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID
    INNER JOIN Orders O ON OD.OrderID = O.OrderID
WHERE
    O.OrderStatus NOT LIKE 'denied'
GROUP BY
    P.Name,
    P.Description,
    DATEPART(iso_week, cast(O.OrderDate AS DATE)),
    DATEPART(YEAR, cast(O.OrderDate AS DATE))
GO
    -- Products summary  weekly --
    -- Products summary Monthly --
    CREATE VIEW dbo.ProductsSummaryMonthly AS
SELECT
    P.Name,
    P.Description,
    DATEPART(MONTH, cast(O.OrderDate AS DATE)) AS 'Miesiac',
    DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
    count(OD.ProductID) AS 'Liczba zamowionych produktow'
FROM
    Products P
    INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID
    INNER JOIN Orders O ON OD.OrderID = O.OrderID
WHERE
    O.OrderStatus NOT LIKE 'denied'
GROUP BY
    P.Name,
    P.Description,
    DATEPART(MONTH, cast(O.OrderDate AS DATE)),
    DATEPART(YEAR, cast(O.OrderDate AS DATE))
GO
    -- Products summary Monthly --
    -- Not reserved Tables --
    -- Kto wydał dane zamówienie
    CREATE
    OR ALTER VIEW dbo.Waiters AS
SELECT
    FirstName + ' ' + LastName AS Name,
    OrderID AS id
FROM
    Staff
    JOIN Orders O ON Staff.StaffID = O.staffID
WHERE
    Position = 'waiter'
    OR Position = 'waitress';

GO
    -- Jakie zamówienia są na wynos
    CREATE
    OR ALTER VIEW dbo.AllTakeaways AS
SELECT
    TakeawayID,
    PrefDate,
    OrderID,
    ClientID,
    PaymentStatusID,
    concat(S.LastName, ' ', S.FirstName) AS 'Dane kelnera',
    Position,
    OrderSum,
    OrderDate,
    OrderCompletionDate,
    OrderStatus
FROM
    OrdersTakeaways
    JOIN Orders O ON OrdersTakeaways.TakeawaysID = O.TakeawayID
    JOIN Staff S ON O.staffID = S.StaffID
GO
    -- Jakie zamówienia są w trakcie przygotowywania
create or alter view dbo.OrdersToPrepare as
    select OrderID, ClientID, TakeawayID, PaymentStatusName,PM.PaymentName,
           concat(S.LastName, ' ',S.FirstName) as 'Dane kelnera',
            OrderSum, OrderDate, PrefDate
    from Orders O join OrdersTakeaways OT on O.TakeawayID = OT.TakeawaysID
        inner join PaymentStatus PS on PS.PaymentStatusID = O.PaymentStatusID
        inner join PaymentMethods PM on PM.PaymentMethodID = O.PaymentMethodID
        inner join Staff S on O.staffID = S.StaffID
    where (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)) and OrderStatus = 'pending')
go
    -- Ile jest zamówień które będą realizowane jako owoce morza i które to są grupowane po klientach
    CREATE
    OR ALTER VIEW dbo.SeeFoodOrdersByClient AS
SELECT
    count(OD.OrderID) AS 'Liczba zamowien z owocami morza',
    Orders.OrderID
FROM
    Orders
    JOIN OrderDetails OD ON Orders.OrderID = OD.OrderID
    JOIN Products P ON P.ProductID = OD.ProductID
    JOIN Category C ON C.CategoryID = P.CategoryID
WHERE
    CategoryName = 'sea food'
    AND (OrderStatus NOT LIKE 'denied')
    AND (
        (
            OrderCompletionDate IS NULL
            AND (getdate() >= OrderDate)
        )
    )
GROUP BY
    CategoryName,
    Orders.OrderID
GO
    -- Ile jest zamówień które będą realizowane jako owoce morza i które to są 
    CREATE
    OR ALTER VIEW dbo.SeeFoodOrders AS
SELECT
    count(OD.OrderID) AS 'Liczba zamowien z owocami morza'
FROM
    Orders
    JOIN OrderDetails OD ON Orders.OrderID = OD.OrderID
    JOIN Products P ON P.ProductID = OD.ProductID
    JOIN Category C ON C.CategoryID = P.CategoryID
WHERE
    CategoryName = 'sea food'
    AND (OrderStatus NOT LIKE 'denied')
    AND (
        (
            OrderCompletionDate IS NULL
            AND (getdate() >= OrderDate)
        )
    )
GROUP BY
    CategoryName
GO
    -- Aktualnie nałożone zniżki na klientów
    CREATE
    OR ALTER VIEW CurrentDiscounts AS
SELECT
    FirstName,
    LastName,
    IC.ClientID,
    DiscountID,
    AppliedDate,
    startDate,
    endDate,
    DiscountType,
    DiscountValue,
    MinimalOrders,
    MinimalAggregateValue,
    ValidityPeriod
FROM
    DiscountsVar
    JOIN Discounts ON DiscountsVar.VarID = Discounts.VarID
    JOIN IndividualClient IC ON Discounts.ClientID = IC.ClientID
    JOIN Person P ON P.PersonID = IC.PersonID
WHERE
    (
        (
            (getdate() >= startDate)
            AND (getdate() <= endDate)
        )
        OR (
            (getdate() >= startDate)
            AND (endDate IS NULL)
        )
    )
GO
    -- informacje na temat wszystkich przyznanych zniżek
    CREATE
    OR ALTER VIEW AllDiscounts AS
SELECT
    IC.PersonID,
    LastName,
    FirstName,
    IC.ClientID,
    DiscountsVar.VarID,
    DiscountType,
    MinimalOrders,
    MinimalAggregateValue,
    ValidityPeriod,
    DiscountValue,
    startDate,
    endDate,
    DiscountID,
    AppliedDate
FROM
    DiscountsVar
    JOIN Discounts ON DiscountsVar.VarID = Discounts.VarID
    JOIN IndividualClient IC ON Discounts.ClientID = IC.ClientID
    JOIN Person P ON P.PersonID = IC.PersonID
GO
    -- Dania wymagane na dzisiaj na wynos
    CREATE
    OR ALTER VIEW DishesInProgressTakeaways AS
SELECT
    Name,
    count(Products.ProductID) AS 'Liczba zamowien',
    sum(Quantity) AS 'Liczba sztuk'
FROM
    Products
    JOIN OrderDetails OD ON Products.ProductID = OD.ProductID
    JOIN Orders ON OD.OrderID = Orders.OrderID
    JOIN OrdersTakeaways OT ON Orders.TakeawayID = OT.TakeawaysID
WHERE
    (
        (
            (getdate() >= OrderDate)
            AND (getdate() <= OrderCompletionDate)
        )
    )
    AND (
        Orders.OrderStatus NOT LIKE 'denied'
        OR Orders.OrderStatus NOT LIKE 'cancelled'
    )
GROUP BY
    Name
GO
    -- Dania wymagane na dzisiaj w rezerwacji
    CREATE
    OR ALTER VIEW DishesInProgressReservation AS
SELECT
    Name,
    count(Products.ProductID) AS 'Liczba zamowien',
    sum(Quantity) AS 'Liczba sztuk'
FROM
    Products
    JOIN OrderDetails OD ON Products.ProductID = OD.ProductID
    JOIN Orders ON OD.OrderID = Orders.OrderID
    JOIN Reservation R2 ON Orders.ReservationID = R2.ReservationID
WHERE
    (
        (
            (getdate() >= OrderDate)
            AND (getdate() <= OrderCmpletionDate)
        )
    )
    AND Orders.OrderStatus NOT LIKE 'denied'
    AND (
        R2.Status NOT LIKE 'denied'
        OR R2.Status NOT LIKE 'cancelled'
    )
GROUP BY
    Name
GO
    -- Products information --
create view dbo.ProductsInformation as
    select Name, P.Description, CategoryName, iif(IsAvailable = 1, 'Aktywne', 'Nieaktywne') as 'Czy produkt aktywny',
           IIF(P.ProductID in (select ProductID
                            from MenuDetails M
                            INNER JOIN Menu M2 on M2.MenuID = M.MenuID
                            where ((startDate >= getdate()) and (endDate >= getdate()))
                                or ((startDate >= getdate()) and endDate is null) and P.ProductID = M.ProductID),
               'Aktualnie w menu', 'Nie jest w menu') as 'Czy jest aktualnie w menu', count(OD.ProductID) as 'Ilosc zamowien danego produktu'
   from Products P
        inner join Category C on C.CategoryID = P.CategoryID
        inner join OrderDetails OD on P.ProductID = OD.ProductID
    group by Name, P.Description, CategoryName, P.ProductID, IsAvailable
go
    -- Products information --
    -- Meal menu info -- 
    CREATE VIEW mealMenuInfo AS
SELECT
    DISTINCT M.MenuID,
    M2.startDate,
    M2.endDate,
    M.ProductID,
    ISNULL(
        (
            SELECT
                SUM(Quantity)
            FROM
                Products P
                INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID
                AND P.ProductID = M.ProductID
                INNER JOIN Orders O ON O.OrderID = OD.OrderID
            WHERE
                (
                    O.OrderDate BETWEEN M2.startDate
                    AND M2.endDate
                )
            GROUP BY
                P.Name
        ),
        0
    ) times_sold
FROM
    MenuDetails M
    INNER JOIN Menu M2 ON M.MenuID = M2.MenuID
GO
    -- Meal menu info -- 


CREATE VIEW dbo.clientExpensesReport AS
    SELECT
        YEAR(O.OrderDate) AS [Year],
        isnull(convert(varchar(50),  MONTH(O.OrderDate), 120), 'Podsumowanie miesiaca') AS [Month],
        isnull(convert(varchar(50),  DATEPART(iso_week , O.OrderDate), 120), 'Podsumowanie tygodnia') AS [WEEK],
        C.ClientID,
        SUM(O.OrderSum) AS [wydane środki]
    FROM Orders AS O
    INNER JOIN Clients C ON C.ClientID = O.ClientID
    INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    INNER JOIN Products P ON P.ProductID = OD.ProductID
    INNER JOIN MenuDetails M ON M.ProductID = P.ProductID
    GROUP BY GROUPING SETS (
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate), DATEPART(iso_week, O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (C.ClientID, YEAR(O.OrderDate))
        )
GO




    -- Clients statistics --
CREATE VIEW ClientStatistics AS
    SELECT C.ClientID,
            C2.CityName + ' ' + A.street + ' ' + A.LocalNr + ' ' + A.PostalCode as Address,
            C.Phone,
            C.Email,
            COUNT(O.OrderID) as [times ordered],
            ISNULL((SELECT [value ordered]
                    FROM (SELECT ClientID, SUM(value) [value ordered]
                         FROM (SELECT O.ClientID ClientID, OD.Quantity * (SELECT Price FROM MenuDetails M2
                                                                                        WHERE  M2.ProductID = OD.ProductID) value
                                FROM OrderDetails OD
                                    INNER JOIN Orders O on O.OrderID = OD.OrderID) OUT
                        GROUP BY ClientID) a
                    WHERE ClientID = C.ClientID), 0) [value ordered]
    FROM Clients C
        LEFT JOIN Orders O ON C.ClientID = O.ClientID
        INNER JOIN Address A on A.AddressID = C.AddressID
        INNER JOIN Cities C2 on C2.CityID = A.CityID
    GROUP BY C.ClientID, C2.CityName + ' ' + A.street + ' ' + A.LocalNr + ' ' + A.PostalCode, C.Phone, C.Email
GO
    -- Clients statistics --


    CREATE VIEW dbo.ReservationSummaryMonthly AS
SELECT
    R.ReservationID,
    R.startDate,
    R.endDate,
    R.Status,
    O.ClientID,
    DATEPART(MONTH, cast(O.OrderDate AS DATE)) AS 'Miesiac',
    DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
    count(OD.ProductID) AS 'Liczba zamowionych produktow'
FROM
    Reservation R
    INNER JOIN Orders O on R.ReservationID = O.ReservationID
    INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
WHERE
    O.OrderStatus NOT LIKE 'denied'
GROUP BY
    R.ReservationID,
    R.startDate,
    R.endDate,
    R.Status,
    O.ClientID,
    DATEPART(MONTH, cast(O.OrderDate AS DATE)),
    DATEPART(YEAR, cast(O.OrderDate AS DATE))
GO


    CREATE VIEW dbo.ReservationSummaryWeekly AS
SELECT
    R.ReservationID,
    R.startDate,
    R.endDate,
    R.Status,
    O.ClientID,
    DATEPART(iso_week, cast(O.OrderDate AS DATE)) AS 'Tydzien',
    DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
    count(OD.ProductID) AS 'Liczba zamowionych produktow'
FROM
    Reservation R
    INNER JOIN Orders O on R.ReservationID = O.ReservationID
    INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
WHERE
    O.OrderStatus NOT LIKE 'denied'
GROUP BY
    R.ReservationID,
    R.startDate,
    R.endDate,
    R.Status,
    O.ClientID,
    DATEPART(iso_week, cast(O.OrderDate AS DATE)),
    DATEPART(YEAR, cast(O.OrderDate AS DATE))
GO