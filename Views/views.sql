-- Current menu view --
CREATE VIEW dbo.CurrentMenu AS
    SELECT M1.MenuID, Price, Name, P.Description AS 'Product Description', M2.Description AS 'Menu Description', startDate, ISNULL(CONVERT(varchar(max), endDate, 120), 'Menu nie ma daty końca') AS 'endDate' FROM MenuDetails M1
        INNER JOIN Products P ON P.ProductID = M1.ProductID
        INNER JOIN Menu M2 ON M1.MenuID = M2.MenuID
    WHERE ((getdate() >= startDate) AND (getdate() <= endDate)) OR ((getdate() >= startDate) AND endDate IS NULL);
GO

GO
-- Current menu view --

-- Current reservation vars --
CREATE VIEW dbo.CurrentReservationVars
AS
    SELECT
        WZ AS [Minimal number of orders],
        WK AS [Minimal value for orders],
        startDate,
        isnull(
            CONVERT(varchar(20), endDate, 120),
            'Obowiązuje zawsze'
        ) AS 'Koniec daty obowiązywania zmiennej'
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
-- Current reservation vars --

-- unpaid invoices  Individuals--
CREATE VIEW dbo.UnPaidInvoicesIndividuals
AS
    SELECT
        InvoiceNumber AS [Numer faktury],
        InvoiceDate AS [Data wystawienia],
        DueDate AS [Data terminu zaplaty],
        concat(LastName, ' ', FirstName) AS [Dane],
        Phone,
        Email,
        concat(CityName, ' ', street, ' ', LocalNr) AS [Adres],
        PostalCode
    FROM Invoice I
        INNER JOIN Clients C ON C.ClientID = I.ClientID
        INNER JOIN Address A ON C.AddressID = A.AddressID
        INNER JOIN IndividualClient IC ON C.ClientID = IC.ClientID
        INNER JOIN Person P ON P.PersonID = IC.PersonID
        INNER JOIN Cities C2 ON C2.CityID = A.CityID
        INNER JOIN PaymentStatus PS ON I.PaymentStatusID = PS.PaymentStatusID
    WHERE
        LOWER(PaymentStatusName) LIKE 'unpaid';
GO
-- unpaid invoices  Individuals--

-- unpaid invoices  Company--
CREATE VIEW dbo.UnPaidInvoicesCompanies
AS
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
    FROM Invoice
        INNER JOIN Clients C ON C.ClientID = Invoice.ClientID
        INNER JOIN Companies CO ON CO.ClientID = C.ClientID
        INNER JOIN Address A ON C.AddressID = A.AddressID
        INNER JOIN Cities C2 ON C2.CityID = A.CityID
        INNER JOIN PaymentStatus PS ON Invoice.PaymentStatusID = PS.PaymentStatusID
    WHERE
        (LOWER(PaymentStatusName) LIKE 'Unpaid');
GO
-- unpaid invoices  Company--

-- withdrawn products --
CREATE VIEW dbo.WithdrawnProducts AS
    SELECT
        Name,
        P.Description,
        C.CategoryName
    FROM Products P
        INNER JOIN Category C ON C.CategoryID = P.CategoryID
    WHERE
        P.IsAvailable = 0
GO
-- withdrawn products --

-- active products --
CREATE VIEW dbo.ActiveProducts
AS
    SELECT Name, P.Description, C.CategoryName
    FROM Products P
        INNER JOIN Category C ON C.CategoryID = P.CategoryID
    WHERE
        P.IsAvailable = 1
GO
-- active products --

-- Active Tables --
CREATE VIEW dbo.ActiveTables 
AS
    SELECT
        TableID,
        ChairAmount
    FROM Tables
    WHERE
        isActive = 1
GO
-- Active Tables --

-- withdrawn tables
CREATE VIEW dbo.[WithdrawnTables]
AS
    SELECT
        TableID,
        ChairAmount
    FROM Tables
        WHERE TableID not in (SELECT TableID FROM ActiveTables)
GO
-- withdrawn tables

-- Not reserved Tables --
CREATE VIEW dbo.[Not reserved Tables] 
AS
        SELECT
            TableID,
            ChairAmount
        FROM Tables
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
            ) AND isActive = 1
    UNION
        SELECT
            TableID,
            ChairAmount
        FROM Tables
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
            ) AND isActive = 1
GO
-- Not reserved Tables --

-- weekly raport about tables --
CREATE VIEW dbo.TablesWeekly 
AS
        SELECT
            YEAR(R2.StartDate) AS year,
            DATEPART(iso_week, R2.StartDate) AS week,
            T.TableID AS table_id,
            T.ChairAmount AS table_size,
            COUNT(RD.TableID) AS how_many_times_reserved
        FROM Tables T
            INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
            INNER JOIN ReservationIndividual RI ON RI.ReservationID = RD.ReservationID
            INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
        WHERE
            (
                LOWER(STATUS) NOT LIKE 'cancelled'
                AND LOWER(STATUS) NOT LIKE 'denied'
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
        FROM Tables T
            INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
            INNER JOIN ReservationCompany RI ON RI.ReservationID = RD.ReservationID
            INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
        WHERE
            (
                LOWER(STATUS) NOT LIKE 'cancelled'
                AND LOWER(STATUS) NOT LIKE 'denied'
            )
        GROUP BY
            YEAR(R2.StartDate),
            DATEPART(iso_week, R2.StartDate),
            T.TableID,
            T.ChairAmount
GO
-- weekly raport about tables --

-- monthly raport about tables --
CREATE VIEW dbo.TablesMonthly 
AS
        SELECT
            YEAR(R2.StartDate) AS year,
            DATEPART(MONTH, R2.StartDate) AS MONTH,
            T.TableID AS table_id,
            T.ChairAmount AS table_size,
            COUNT(RD.TableID) AS how_many_times_reserved
        FROM Tables T
            INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
            INNER JOIN ReservationIndividual RI ON RI.ReservationID = RD.ReservationID
            INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
        WHERE
            (
                LOWER(STATUS) NOT LIKE 'cancelled'
                AND LOWER(STATUS) NOT LIKE 'denied'
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
            Tables T
            INNER JOIN ReservationDetails RD ON T.TableID = RD.TableID
            INNER JOIN ReservationCompany RI ON RI.ReservationID = RD.ReservationID
            INNER JOIN Reservation R2 ON RD.ReservationID = R2.ReservationID
        WHERE
            (
                LOWER(STATUS) NOT LIKE 'cancelled'
                AND LOWER(STATUS) NOT LIKE 'denied'
            )
        GROUP BY
            YEAR(R2.StartDate),
            DATEPART(MONTH, R2.StartDate),
            T.TableID,
            T.ChairAmount
GO
-- monthly raport about tables --

-- takeaway orders not picked Individuals--
CREATE VIEW dbo.[Takeaways orders not picked Individuals]
AS
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
    FROM OrdersTakeaways OT
        INNER JOIN Orders O ON OT.TakeawaysID = O.TakeawayID
        INNER JOIN Clients C ON O.ClientID = C.ClientID
        INNER JOIN IndividualClient IC ON C.ClientID = IC.ClientID
        INNER JOIN Person P ON IC.PersonID = P.PersonID
        INNER JOIN Address A ON C.AddressID = A.AddressID
        INNER JOIN Cities C2 ON A.CityID = C2.CityID
    WHERE
        LOWER(OrderStatus) LIKE 'Completed'
GO
-- takeaways orders not picked Individuals--

-- takeaways orders not picked Companies--
CREATE VIEW dbo.[Takeaways orders not picked Companies]
AS
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
    FROM OrdersTakeaways OT
        INNER JOIN Orders O ON OT.TakeawaysID = O.TakeawayID
        INNER JOIN Clients C ON O.ClientID = C.ClientID
        INNER JOIN Companies CO ON C.ClientID = CO.ClientID
        INNER JOIN Address A ON C.AddressID = A.AddressID
        INNER JOIN Cities C2 ON A.CityID = C2.CityID
    WHERE
        LOWER(OrderStatus) LIKE 'Completed'
GO
-- takeaways orders not picked Companies--

-- takeaway orders  Individuals--
CREATE VIEW dbo.[Takeaways orders Individuals]
AS
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
    FROM OrdersTakeaways OT
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
CREATE VIEW dbo.[Takeaways orders companies]
AS
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
    FROM OrdersTakeaways OT
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
CREATE VIEW ReservationInfo 
AS
    SELECT
        R.ReservationID,
        TableID,
        StartDate,
        EndDate
    FROM
        Reservation R
        LEFT OUTER JOIN ReservationDetails RD ON RD.ReservationID = R.ReservationID
    WHERE
        LOWER(STATUS) NOT LIKE 'cancelled'
GO
-- ReservationInfo --

-- ReservationDenied --
CREATE VIEW ReservationDenied
AS
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
-- TODO TEST
CREATE VIEW dbo.OrdersReport AS
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
CREATE VIEW dbo.IndividualClientExpensesReport
AS
    SELECT
--             TODO check
        DISTINCT isnull(
            CONVERT(varchar(50), YEAR(O.OrderDate), 120),
            'Podsumowanie Roku'
        ) AS [Year],
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
        concat(C2.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
        A.PostalCode,
        ISNULL(SUM(O.OrderSum), 0) AS [wydane środki]
    FROM Orders O
        RIGHT JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
        INNER JOIN Person P2 ON P2.PersonID = IC.PersonID
        INNER JOIN Address A ON A.AddressID = C.AddressID
        INNER JOIN Cities C2 on C2.CityID = A.CityID
    GROUP BY
        GROUPING SETS (
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                DATEPART(iso_week, O.OrderDate),
                CONCAT(P2.LastName, ' ', P2.FirstName),
                C.ClientID,
                C.Phone,
                C.Email,
                concat(C2.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode
            ),
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                CONCAT(P2.LastName, ' ', P2.FirstName),
                C.ClientID,
                C.Phone,
                C.Email,
                concat(C2.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode
            ),
            (
                CONCAT(P2.LastName, ' ', P2.FirstName),
                C.ClientID,
                C.Phone,
                C.Email,
                concat(C2.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode,
                YEAR(O.OrderDate)
            )
        )
GO
--individualClients expenses report

--company expenses report (wyświetlanie wydanych kwot przez firmy w okresach czasowych)
CREATE VIEW dbo.companyExpensesReport 
AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(iso_week , O.OrderDate) AS [Tydzień],
        C.ClientID,
        C2.CompanyName,
        C2.NIP,
        ISNULL(cast(C2.KRS AS varchar), 'Brak') AS [KRS],
        ISNULL(cast(C2.Regon AS varchar), 'Brak') AS [Regon],
        C.Phone,
        C.Email,
        CONCAT(C2.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
        A.PostalCode,
        SUM(O.OrderSum) AS [wydane środki]
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
        INNER JOIN Address A ON A.AddressID = C.AddressID
        INNER JOIN Cities C2 on C2.CityID = A.CityID
    GROUP BY
        GROUPING SETS (
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                DATEPART(iso_week , O.OrderDate),
                C.ClientID,
                C2.CompanyName,
                C2.NIP,
                ISNULL(cast(C2.KRS AS varchar), 'Brak'),
                ISNULL(cast(C2.Regon AS varchar), 'Brak'),
                C.Phone,
                C.Email,
                CONCAT(C2.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode
            ),
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                C.ClientID,
                C2.CompanyName,
                C2.NIP,
                ISNULL(cast(C2.KRS AS varchar), 'Brak'),
                ISNULL(cast(C2.Regon AS varchar), 'Brak'),
                C.Phone,
                C.Email,
                CONCAT(C2.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode
            ),
            (
                YEAR(O.OrderDate),
                C.ClientID,
                C2.CompanyName,
                C2.NIP,
                ISNULL(cast(C2.KRS AS varchar), 'Brak'),
                ISNULL(cast(C2.Regon AS varchar), 'Brak'),
                C.Phone,
                C.Email,
                CONCAT(C2.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode
            )
        )
GO
--company expenses report

--Number of individual clients (ilość klientów indywidualnych w okresach czasu)
CREATE VIEW dbo.numberOfIndividualClients 
AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(iso_week , O.OrderDate) AS [Tydzień],
        COUNT(DISTINCT C.ClientID) AS [Ilość klientów indywidualnych]
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
    GROUP BY
        GROUPING SETS (
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                DATEPART(iso_week , O.OrderDate)
            ),
            (YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (YEAR(O.OrderDate))
        )
GO
--Number of clients

--Number of companies (ilość firm w okresach czasu)
CREATE VIEW dbo.numberOfCompanies 
AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(iso_week , O.OrderDate) AS [Tydzień],
        COUNT(DISTINCT C.ClientID) AS [Ilość zamawiających firm]
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
    GROUP BY
        GROUPING SETS (
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                DATEPART(iso_week, O.OrderDate)
            ),
            (YEAR(O.OrderDate), MONTH(O.OrderDate)),
            (YEAR(O.OrderDate))
        )
GO
--Number of companies

--Number of orders individual client       (ilość zamówień złożonych przez klientów indywidualnych w okresach czasu)
CREATE VIEW dbo.individualClientNumberOfOrders 
AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(iso_week , O.OrderDate) AS [Tydzień],
        C.ClientID,
        CONCAT(P2.LastName, ' ', P2.FirstName) AS [Dane],
        C.Phone,
        C.Email,
        concat(C2.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
        A.PostalCode,
        COUNT(DISTINCT O.OrderID) AS [Ilość złożonych zamówień]
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
        INNER JOIN Person P2 ON P2.PersonID = IC.PersonID
        INNER JOIN Address A ON A.AddressID = C.AddressID
        INNER JOIN Cities C2 on C2.CityID = A.CityID
    GROUP BY
        GROUPING SETS (
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                DATEPART(iso_week , O.OrderDate),
                C.ClientID,
                CONCAT(P2.LastName, ' ', P2.FirstName),
                C.Phone,
                C.Email,
                concat(C2.CityName, ' ', A.street, ' ', A.LocalNr) ,
                A.PostalCode
            ),
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                C.ClientID,
                CONCAT(P2.LastName, ' ', P2.FirstName),
                C.Phone,
                C.Email,
                concat(C2.CityName, ' ', A.street, ' ', A.LocalNr) ,
                A.PostalCode
            ),
            (
                YEAR(O.OrderDate),
                C.ClientID,
                CONCAT(P2.LastName, ' ', P2.FirstName),
                C.Phone,
                C.Email,
                concat(C2.CityName, ' ', A.street, ' ', A.LocalNr) ,
                A.PostalCode
            )
        )
GO
--Number of orders individual client

--Number of orders companies       (ilość zamówień złożonych przez firmy w okresach czasu)
CREATE VIEW dbo.companiesNumberOfOrders 
AS
    SELECT
        YEAR(O.OrderDate) AS [Rok],
        MONTH(O.OrderDate) AS [Miesiąc],
        DATEPART(iso_week, O.OrderDate) AS [Tydzień],
        C.ClientID,
        C2.CompanyName,
        C2.NIP,
        ISNULL(cast(C2.KRS AS varchar), 'Brak') AS [KRS],
        ISNULL(cast(C2.Regon AS varchar), 'Brak') AS [Regon],
        C.Phone,
        C.Email,
        CONCAT(C3.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
        A.PostalCode,
        COUNT(DISTINCT O.OrderID) AS [Ilość złożonych zamówień]
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
        INNER JOIN Address A ON A.AddressID = C.AddressID
        INNER JOIN Cities C3 on C3.CityID = A.CityID
    GROUP BY
        GROUPING SETS (
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                DATEPART(iso_week, O.OrderDate),
                C.ClientID,
                C2.CompanyName,
                C2.NIP,
                ISNULL(cast(C2.KRS AS varchar), 'Brak') ,
                ISNULL(cast(C2.Regon AS varchar), 'Brak'),
                C.Phone,
                C.Email,
                CONCAT(C3.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode
            ),
            (
                YEAR(O.OrderDate),
                MONTH(O.OrderDate),
                C.ClientID,
                C2.CompanyName,
                C2.NIP,
                ISNULL(cast(C2.KRS AS varchar), 'Brak') ,
                ISNULL(cast(C2.Regon AS varchar), 'Brak'),
                C.Phone,
                C.Email,
                CONCAT(C3.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode
            ),
            (
                YEAR(O.OrderDate),
                C.ClientID,
                C2.CompanyName,
                C2.NIP,
                ISNULL(cast(C2.KRS AS varchar), 'Brak') ,
                ISNULL(cast(C2.Regon AS varchar), 'Brak'),
                C.Phone,
                C.Email,
                CONCAT(C3.CityName, ' ', A.street, ' ', A.LocalNr),
                A.PostalCode

            )
        )
GO
--Number of orders companies

--individual clients who have not paid for their orders (klienci indywidualni, którzy mają nieopłacone zamówienia oraz jaka jest ich należność)
CREATE VIEW dbo.IndividualClientsWhoNotPayForOrders
AS
    SELECT
        C.ClientID,
        CONCAT(P.LastName, ' ', P.FirstName) AS [Dane],
        C.Phone,
        C.Email,
        concat(C2.CityName, ' ', A.street, ' ', A.LocalNr) AS [Adres],
        A.PostalCode,
        O.OrderDate,
        SUM(O.OrderSum) AS [money to pay]
    FROM Clients C
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
CREATE VIEW dbo.CompaniesWhoNotPayForOrders
AS
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
    FROM Clients C
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
CREATE VIEW dbo.ordersonSite 
AS
    SELECT
        O.OrderID,
        O.ClientID,
        C.Phone,
        C.Email,
        OD.Quantity,
        P.Name
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
        INNER JOIN Products P ON P.ProductID = OD.ProductID
    WHERE
        (O.TakeawayID IS NULL)
        AND (O.OrderStatus LIKE 'accepted')
GO
--orders on-site             (zamówienia na miejscu, które są przygotowywane)

--takeaway orders in progress      (zamówienia na wynos, które są przygotowywane dla klientów indywidualnych)
CREATE VIEW dbo.takeawayOrdersInProgressIndividual 
AS
    SELECT
        O.OrderID,
        O.ClientID,
        C.Phone,
        C.Email,
        concat(P.LastName, ' ', P.FirstName) AS [Dane],
        OD.Quantity,
        P.Name,
        OT.PrefDate
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
        INNER JOIN Person P ON P.PersonID = IC.PersonID
        INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
        INNER JOIN Products P ON P.ProductID = OD.ProductID
        INNER JOIN OrdersTakeaways OT ON OT.TakeawaysID = O.TakeawayID
    WHERE
        (O.OrderStatus LIKE 'accepted')
GO
--takeaway orders in progress      (zamówienia na wynos, które są przygotowywane dla klientów indywidualnych)

--takeaway orders in progress Companies
CREATE VIEW dbo.takeawayOrdersInProgressCompanies 
AS
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
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN Companies C2 ON C2.ClientID = C.ClientID
        INNER JOIN OrderDetails OD ON OD.OrderID = O.OrderID
        INNER JOIN Products P ON P.ProductID = OD.ProductID
        INNER JOIN OrdersTakeaways OT ON OT.TakeawaysID = O.TakeawayID
    WHERE
        (O.OrderStatus LIKE 'accepted')
GO
--takeaway orders in progress Companies

--orders for individual clients information - (informacje o zamówieniach dla klientów indywidualnych)
-- TODO TEST
CREATE VIEW dbo.OrdersInformationIndividualClient
AS
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
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN IndividualClient IC ON IC.ClientID = C.ClientID
        INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
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
-- TODO TEST
CREATE VIEW dbo.OrdersInformationCompany
AS
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
    FROM Orders O
        INNER JOIN Clients C ON C.ClientID = O.ClientID
        INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
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
CREATE VIEW dbo.PendingReservationsCompanies 
AS
    SELECT
        R.ReservationID,
        startDate,
        endDate,
        OrderID,
        OrderSum
    FROM Reservation R
        INNER JOIN ReservationCompany RC ON RC.ReservationID = R.ReservationID
        INNER JOIN Orders O ON R.ReservationID = O.ReservationID
    WHERE
        LOWER(STATUS) LIKE 'pending'
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
    FROM Reservation R
        INNER JOIN ReservationIndividual RC ON RC.ReservationID = R.ReservationID
        INNER JOIN Orders O ON R.ReservationID = O.ReservationID
    WHERE
        LOWER(STATUS) LIKE 'pending'
GO
-- PendingReservation Individual--

-- Reservation accepted by --
CREATE VIEW dbo.ReservationAcceptedBy 
AS
    SELECT
        concat(LastName, ' ', FirstName) AS Dane,
        Position,
        Email,
        Phone
    FROM Staff
        INNER JOIN Reservation R2 ON Staff.StaffID = R2.StaffID
    WHERE
        LOWER(STATUS) LIKE 'accepted'
GO
-- Reservation accepted by --

-- Reservation summary --
CREATE VIEW dbo.ReservationSummary 
AS
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
        FROM Reservation
            INNER JOIN Orders O ON Reservation.ReservationID = O.ReservationID
            INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
            INNER JOIN ReservationCompany RC ON Reservation.ReservationID = RC.ReservationID
            INNER JOIN ReservationDetails RD ON RC.ReservationID = RD.ReservationID
        WHERE
            LOWER(STATUS) NOT LIKE 'denied' AND LOWER(STATUS) NOT LIKE 'cancelled' AND LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
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
        FROM Reservation
            INNER JOIN Orders O ON Reservation.ReservationID = O.ReservationID
            INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
            INNER JOIN ReservationIndividual RC ON Reservation.ReservationID = RC.ReservationID
            INNER JOIN ReservationDetails RD ON RC.ReservationID = RD.ReservationID
        WHERE
            LOWER(STATUS) NOT LIKE 'denied' AND LOWER(STATUS) NOT LIKE 'cancelled' AND LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
GO
-- Reservation summary --

-- Products summary Daily --
CREATE VIEW dbo.ProductsSummaryDaily 
AS
    SELECT
        P.Name,
        P.Description,
        cast(O.OrderDate AS DATE) AS 'Dzien',
        count(OD.ProductID) AS 'Liczba zamowionych produktow'
    FROM Products P
        INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID
        INNER JOIN Orders O ON OD.OrderID = O.OrderID
    WHERE
            LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
    GROUP BY
        P.Name,
        P.Description,
        cast(O.OrderDate AS DATE)
GO
-- Products summary Daily --

-- Products summary  weekly --
CREATE VIEW dbo.ProductsSummaryWeekly 
AS
    SELECT
        P.Name,
        P.Description,
        DATEPART(iso_week, cast(O.OrderDate AS DATE)) AS 'Tydzien',
        DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
        count(OD.ProductID) AS 'Liczba produktow'
    FROM Products P
        INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID
        INNER JOIN Orders O ON OD.OrderID = O.OrderID
    WHERE
        LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
    GROUP BY
        P.Name,
        P.Description,
        DATEPART(iso_week, cast(O.OrderDate AS DATE)),
        DATEPART(YEAR, cast(O.OrderDate AS DATE))
GO
-- Products summary  weekly --

-- Products summary Monthly --
CREATE VIEW dbo.ProductsSummaryMonthly 
AS
    SELECT
        P.Name,
        P.Description,
        DATEPART(MONTH, cast(O.OrderDate AS DATE)) AS 'Miesiac',
        DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
        count(OD.ProductID) AS 'Liczba zamowionych produktow'
    FROM Products P
        INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID
        INNER JOIN Orders O ON OD.OrderID = O.OrderID
    WHERE
        LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
    GROUP BY
        P.Name,
        P.Description,
        DATEPART(MONTH, cast(O.OrderDate AS DATE)),
        DATEPART(YEAR, cast(O.OrderDate AS DATE))
GO
-- Products summary Monthly --

-- Kto wydał dane zamówienie
CREATE OR ALTER VIEW dbo.WhoIssuedAnOrder
AS
    SELECT
        FirstName + ' ' + LastName AS Name,
        OrderID AS id
    FROM Staff
        INNER JOIN Orders O ON Staff.StaffID = O.staffID
    WHERE
        LOWER(Position) LIKE 'waiter'
        OR LOWER(Position) LIKE 'waitress';
GO
-- Kto wydał dane zamówienie


-- Jakie zamówienia są na wynos
CREATE OR ALTER VIEW dbo.AllTakeaways
AS
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
    FROM OrdersTakeaways
        JOIN Orders O ON OrdersTakeaways.TakeawaysID = O.TakeawayID
        JOIN Staff S ON O.staffID = S.StaffID
GO
-- Jakie zamówienia są na wynos

-- Jakie zamówienia są w trakcie przygotowywania
CREATE OR ALTER VIEW dbo.OrdersToPrepare 
AS
    SELECT OrderID, ClientID, TakeawayID, PaymentStatusName, PM.PaymentName,
    CONCAT(S.LastName, ' ',S.FirstName) AS 'Dane kelnera',
    OrderSum, OrderDate, PrefDate
    FROM Orders O 
        INNER JOIN OrdersTakeaways OT ON O.TakeawayID = OT.TakeawaysID
        INNER JOIN PaymentStatus PS ON PS.PaymentStatusID = O.PaymentStatusID
        INNER JOIN PaymentMethods PM ON PM.PaymentMethodID = O.PaymentMethodID
        INNER JOIN Staff S ON O.staffID = S.StaffID
    WHERE (((GETDATE() >= OrderDate) AND (GETDATE() <= OrderCompletionDate)) OR (OrderCompletionDate IS NULL AND (GETDATE() >= OrderDate)) AND LOWER(OrderStatus) LIKE 'pending')
GO
-- Jakie zamówienia są w trakcie przygotowywania

-- Ile jest zamówień które będą realizowane jako owoce morza i które to są grupowane po klientach
CREATE OR ALTER VIEW dbo.SeeFoodOrdersByClient 
AS
    SELECT
        count(OD.OrderID) AS 'Liczba zamowien z owocami morza',
        Orders.OrderID
    FROM
        Orders
        INNER JOIN OrderDetails OD ON Orders.OrderID = OD.OrderID
        INNER JOIN Products P ON P.ProductID = OD.ProductID
        INNER JOIN Category C ON C.CategoryID = P.CategoryID
    WHERE
        LOWER(CategoryName) LIKE 'sea food'
        AND (LOWER(OrderStatus) NOT LIKE 'denied')
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
-- Ile jest zamówień które będą realizowane jako owoce morza i które to są grupowane po klientach

-- Ile jest zamówień które będą realizowane jako owoce morza i które to są 
CREATE OR ALTER VIEW dbo.SeeFoodOrders 
AS
    SELECT
        count(OD.OrderID) AS 'Liczba zamowien z owocami morza'
    FROM Orders
        INNER JOIN OrderDetails OD ON Orders.OrderID = OD.OrderID
        INNER JOIN Products P ON P.ProductID = OD.ProductID
        INNER JOIN Category C ON C.CategoryID = P.CategoryID
    WHERE
        LOWER(CategoryName) LIKE 'sea food'
        AND (LOWER(OrderStatus) NOT LIKE 'denied')
        AND (
            (
                OrderCompletionDate IS NULL
                AND (getdate() >= OrderDate)
            )
        )
    GROUP BY
        CategoryName
GO
-- Ile jest zamówień które będą realizowane jako owoce morza i które to są 

-- Aktualnie nałożone zniżki na klientów
CREATE OR ALTER VIEW CurrentDiscounts 
AS
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
    FROM DiscountsVar
        INNER JOIN Discounts ON DiscountsVar.VarID = Discounts.VarID
        INNER JOIN IndividualClient IC ON Discounts.ClientID = IC.ClientID
        INNER JOIN Person P ON P.PersonID = IC.PersonID
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
-- Aktualnie nałożone zniżki na klientów

-- informacje na temat wszystkich przyznanych zniżek
CREATE OR ALTER VIEW AllDiscounts 
AS
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
    FROM DiscountsVar
        INNER JOIN Discounts ON DiscountsVar.VarID = Discounts.VarID
        INNER JOIN IndividualClient IC ON Discounts.ClientID = IC.ClientID
        INNER JOIN Person P ON P.PersonID = IC.PersonID
GO
-- informacje na temat wszystkich przyznanych zniżek

-- Dania wymagane na dzisiaj na wynos
CREATE OR ALTER VIEW DishesInProgressTakeaways 
AS
    SELECT
        Name,
        count(Products.ProductID) AS 'Liczba zamowien',
        sum(Quantity) AS 'Liczba sztuk'
    FROM Products
        INNER JOIN OrderDetails OD ON Products.ProductID = OD.ProductID
        INNER JOIN Orders ON OD.OrderID = Orders.OrderID
        INNER JOIN OrdersTakeaways OT ON Orders.TakeawayID = OT.TakeawaysID
    WHERE
        (
            (
                (getdate() >= OrderDate)
                AND (getdate() <= OrderCompletionDate)
            )
        )
        AND (
            LOWER(Orders.OrderStatus) NOT LIKE 'denied'
            OR LOWER(Orders.OrderStatus) NOT LIKE 'cancelled'
        )
    GROUP BY Name
GO
-- Dania wymagane na dzisiaj na wynos

-- Dania wymagane na dzisiaj w rezerwacji
CREATE OR ALTER VIEW DishesInProgressReservation 
AS
    SELECT
        Name,
        count(Products.ProductID) AS 'Liczba zamowien',
        sum(Quantity) AS 'Liczba sztuk'
    FROM Products
        INNER JOIN OrderDetails OD ON Products.ProductID = OD.ProductID
        INNER JOIN Orders ON OD.OrderID = Orders.OrderID
        INNER JOIN Reservation R2 ON Orders.ReservationID = R2.ReservationID
    WHERE
        (
            (
                (getdate() >= OrderDate)
                AND (getdate() <= OrderCompletionDate)
            )
        )
        AND LOWER(Orders.OrderStatus) NOT LIKE 'denied'
        AND (
            LOWER(R2.Status) NOT LIKE 'denied'
            OR LOWER(R2.Status) NOT LIKE 'cancelled'
        )
    GROUP BY Name
GO
-- Dania wymagane na dzisiaj w rezerwacji

-- Products information --
CREATE VIEW dbo.ProductsInformation 
AS
    SELECT  Name, 
            P.Description, 
            CategoryName, 
            IIF(IsAvailable = 1, 'Aktywne', 'Nieaktywne') AS 'Czy produkt aktywny',
            IIF(P.ProductID IN (SELECT ProductID FROM MenuDetails M
                                INNER JOIN Menu M2 on M2.MenuID = M.MenuID
                            WHERE ((startDate >= getdate()) AND (endDate >= getdate()))
                                OR ((startDate >= getdate()) AND endDate IS NULL) AND P.ProductID = M.ProductID), 'Aktualnie w menu', 'Nie jest w menu') as 'Czy jest aktualnie w menu', 
            count(OD.ProductID) as 'Ilosc zamowien danego produktu'
    FROM Products P
        LEFT JOIN OrderDetails OD ON P.ProductID = OD.ProductID
        INNER JOIN Category C ON C.CategoryID = P.CategoryID
    GROUP BY Name, P.Description, CategoryName, P.ProductID, IsAvailable
GO
-- Products information --

-- Meal menu info -- 
CREATE VIEW MealMenuInfo
AS
    SELECT
        DISTINCT M.MenuID,
        M2.startDate,
        M2.endDate,
        M.ProductID,
        ISNULL(
            (
                SELECT
                    SUM(Quantity)
                FROM Products P
                    INNER JOIN OrderDetails OD ON P.ProductID = OD.ProductID AND P.ProductID = M.ProductID
                    INNER JOIN Orders O ON O.OrderID = OD.OrderID
                WHERE
                    (
                        O.OrderDate BETWEEN M2.startDate
                        AND M2.endDate
                    )
                GROUP BY P.Name
            ),
            0
        ) times_sold
    FROM MenuDetails M
        INNER JOIN Menu M2 ON M.MenuID = M2.MenuID
GO
-- Meal menu info -- 

-- client Expenses Report --
CREATE VIEW dbo.ClientExpensesReport
AS
    SELECT
        YEAR(O.OrderDate) AS [Year],
        isnull(convert(varchar(50),  MONTH(O.OrderDate), 120), 'Podsumowanie miesiaca') AS [Month],
        isnull(convert(varchar(50),  DATEPART(iso_week , O.OrderDate), 120), 'Podsumowanie tygodnia') AS [Week],
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
-- client Expenses Report --

-- current discounts vars 
CREATE VIEW dbo.CurrentDiscountsVars
AS
    SELECT
        VarID,
        DiscountType,
        ISNULL(CAST(MinimalOrders AS varchar), ' ') AS MinimalOrders,
        ISNULL(CAST(MinimalAggregateValue AS varchar), ' ') AS MinimalAggregateValue,
        ISNULL(CAST(ValidityPeriod AS varchar), ' ') AS ValidityPeriod,
        DiscountValue,
        startDate,
        endDate
    FROM dbo.DiscountsVar
    WHERE
        (
            (
                (getdate() >= startDate)
                AND (getdate() <= endDate)
            )
        )
GO
-- current discounts vars 

-- Clients statistics --
CREATE VIEW ClientStatistics
AS
SELECT  C.ClientID,
            C2.CityName + ' ' + A.street + ' ' + A.LocalNr + ' ' + A.PostalCode as Address,
            C.Phone,
            C.Email,
            COUNT(O.OrderID) as [times ordered],
            ISNULL((SELECT [value ordered]
                    FROM (SELECT ClientID, SUM(value) [value ordered]
                            FROM (SELECT O.ClientID as ClientID, O.OrderSum as value
                                    FROM Orders O) OUT
                            GROUP BY ClientID) a
                    WHERE ClientID = C.ClientID), 0) [value ordered]
    FROM Clients C
        LEFT JOIN Orders O ON C.ClientID = O.ClientID
        INNER JOIN Address A on A.AddressID = C.AddressID
        INNER JOIN Cities C2 on C2.CityID = A.CityID
    GROUP BY C.ClientID, C2.CityName + ' ' + A.street + ' ' + A.LocalNr + ' ' + A.PostalCode, C.Phone, C.Email
GO
-- Clients statistics --

-- ReservationSummaryMonthly --
CREATE VIEW dbo.ReservationSummaryMonthly 
AS
    SELECT
        R.ReservationID,
        R.startDate,
        R.endDate,
        R.Status,
        O.ClientID,
        DATEPART(MONTH, cast(O.OrderDate AS DATE)) AS 'Miesiac',
        DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
        count(OD.ProductID) AS 'Liczba zamowionych produktow'
    FROM Reservation R
        INNER JOIN Orders O on R.ReservationID = O.ReservationID
        INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
    WHERE
        LOWER(STATUS) NOT LIKE 'denied' AND LOWER(STATUS) NOT LIKE 'cancelled' AND LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
    GROUP BY
        R.ReservationID,
        R.startDate,
        R.endDate,
        R.Status,
        O.ClientID,
        DATEPART(MONTH, cast(O.OrderDate AS DATE)),
        DATEPART(YEAR, cast(O.OrderDate AS DATE))
GO
-- ReservationSummaryMonthly --

-- ReservationSummaryWeekly --
CREATE VIEW dbo.ReservationSummaryWeekly 
AS
    SELECT
        R.ReservationID,
        R.startDate,
        R.endDate,
        R.Status,
        O.ClientID,
        DATEPART(iso_week, cast(O.OrderDate AS DATE)) AS 'Tydzien',
        DATEPART(YEAR, cast(O.OrderDate AS DATE)) AS 'Rok',
        count(OD.ProductID) AS 'Liczba zamowionych produktow'
    FROM Reservation R
        INNER JOIN Orders O on R.ReservationID = O.ReservationID
        INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
    WHERE
        LOWER(STATUS) NOT LIKE 'denied' AND LOWER(STATUS) NOT LIKE 'cancelled' AND LOWER(O.OrderStatus) NOT LIKE 'denied' AND LOWER(O.OrderStatus) NOT LIKE 'cancelled'
    GROUP BY
        R.ReservationID,
        R.startDate,
        R.endDate,
        R.Status,
        O.ClientID,
        DATEPART(iso_week, cast(O.OrderDate AS DATE)),
        DATEPART(YEAR, cast(O.OrderDate AS DATE))
GO
-- ReservationSummaryWeekly --

-- SeeFoodOrdersByClient
create  view dbo.SeeFoodOrdersByClient as
    select count(OD.OrderID) as N'Liczba zamowien z owocami morza', Orders.OrderID
    from Orders
        join OrderDetails OD on Orders.OrderID = OD.OrderID
        join Products P on P.ProductID = OD.ProductID join Category C on C.CategoryID = P.CategoryID
    where CategoryName='sea food' and (LOWER(OrderStatus) not like 'denied' or LOWER(OrderStatus) not like 'cancelled') and (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)))
    group by CategoryName, Orders.OrderID
go
-- SeeFoodOrdersByClient

-- SeeFoodOrders
create   view dbo.SeeFoodOrders as
    select count(OD.OrderID) as 'Liczba zamowien z owocami morza'
    from Orders
        join OrderDetails OD on Orders.OrderID = OD.OrderID
        join Products P on P.ProductID = OD.ProductID join Category C on C.CategoryID = P.CategoryID
    where CategoryName='sea food' and (LOWER(OrderStatus) not like 'denied' or LOWER(OrderStatus) not like 'cancelled') and (((getdate() >= OrderDate) and (getdate() <= OrderCompletionDate)) or (OrderCompletionDate is null and (getdate() >= OrderDate)))
    group by CategoryName
go
-- SeeFoodOrders

-- show individual clients --
CREATE VIEW dbo.ShowIndividualClients
AS
    SELECT
        C.ClientID,
        P.FirstName,
        P.LastName,
        C.Phone,
        C.Email,
        C2.CityName + ' ' + A.street + ' ' + A.LocalNr + ' ' + A.PostalCode as Address
    FROM Clients C
        INNER JOIN Address A on A.AddressID = C.AddressID
        INNER JOIN Cities C2 on C2.CityID = A.CityID
        INNER JOIN IndividualClient IC on IC.ClientID = C.ClientID
        INNER JOIN Person P on IC.PersonID = P.PersonID
GO
-- show individual clients --

-- show company clients --
CREATE VIEW dbo.ShowCompanyClients
AS
    SELECT
        C.ClientID,
        CompanyName,
        NIP,
        ISNULL(CAST(KRS AS VARCHAR), '') AS KRS,
        ISNULL(CAST(Regon AS VARCHAR), '') AS Regon,
        C.Phone,
        C.Email,
        C2.CityName + ' ' + A.street + ' ' + A.LocalNr + ' ' + A.PostalCode as Address
    FROM Clients C
        INNER JOIN Address A on A.AddressID = C.AddressID
        INNER JOIN Cities C2 on C2.CityID = A.CityID
        INNER JOIN Companies CC on CC.ClientID = C.ClientID
GO
-- show company clients --

-- Discounts Summary

CREATE VIEW DiscountsSummaryPerClient
AS
    SELECT
            IC.ClientID,
            CONCAT(P.LastName, ' ', P.FirstName) AS 'Person',
            DiscountID,
            AppliedDate,
            DiscountType,
            DiscountValue,
            ISNULL(CAST(MinimalOrders AS varchar), '') AS 'Minimal Orders needed',
            ISNULL(CAST(MinimalAggregateValue AS varchar), '') AS 'Minimal Aggregate Value needed',
            ISNULL(CAST(ValidityPeriod AS varchar), '') AS 'Validity Period',
            ISNULL(CAST(isUsed AS varchar), 'It is permanent') AS 'is Used'
    FROM IndividualClient IC
        INNER JOIN Person P on P.PersonID = IC.PersonID
        INNER JOIN Discounts D on IC.ClientID = D.ClientID
        INNER JOIN DiscountsVar DV on D.VarID = DV.VarID
GO
