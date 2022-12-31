-- tables
-- Table: Address
CREATE TABLE Address (
    AddressID int NOT NULL IDENTITY (1, 1),
    CityID INT NOT NULL,
    street nvarchar(70) NOT NULL,
    LocalNr varchar(10) NOT NULL CHECK(localNr LIKE '[0-9]%'),
    PostalCode char(6) NOT NULL CHECK(PostalCode LIKE '[0-9][0-9]-[0-9][0-9][0-9]'),
    CONSTRAINT Address_pk PRIMARY KEY (AddressID)
);

-- Table: Category
CREATE TABLE Category (
    CategoryID int NOT NULL IDENTITY (1, 1),
    CategoryName nvarchar(50) NOT NULL,
    Description nvarchar(150) NOT NULL,
    CONSTRAINT Category_pk PRIMARY KEY (CategoryID)
);

-- Table: Cities
CREATE TABLE Cities (
    CityID INT NOT NULL IDENTITY (1, 1),
    CityName nvarchar(35) NOT NULL,
    CONSTRAINT Cities_pk PRIMARY KEY (CityID)
);

-- Table: Clients
CREATE TABLE Clients (
    ClientID int NOT NULL IDENTITY (1, 1),
    AddressID int NOT NULL,
    Phone varchar(14) NOT NULL UNIQUE CHECK (
        isnumeric(Phone) = 1
        AND len(Phone) >= 9
    ),
    Email varchar(100) NOT NULL UNIQUE CHECK(Email LIKE '%[@]%[.]%'),
    CONSTRAINT Clients_pk PRIMARY KEY (ClientID)
);

-- Table: Companies
CREATE TABLE Companies (
    ClientID int NOT NULL,
    CompanyName nvarchar(50) NOT NULL UNIQUE,
    NIP char(10) NOT NULL UNIQUE CHECK(
        NIP LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    ),
    KRS char(10) NULL UNIQUE CHECK(
        KRS LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    ),
    Regon char(9) NULL UNIQUE CHECK(
        Regon LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    ),
    CONSTRAINT Companies_pk PRIMARY KEY (ClientID)
);

-- Table: Discounts
CREATE TABLE Discounts (
    DiscountID int NOT NULL IDENTITY (1, 1),
    ClientID int NOT NULL,
    VarID int NOT NULL,
    AppliedDate datetime NOT NULL,
    isUsed bit NULL DEFAULT 0,
    CONSTRAINT Discounts_pk PRIMARY KEY (DiscountID)
);

-- Table: DiscountsVar
CREATE TABLE DiscountsVar (
    VarID int NOT NULL IDENTITY (1, 1),
    DiscountType char(9) NOT NULL CHECK (DiscountType IN ('Permanent', 'Temporary')),
    MinimalOrders int NULL,
    MinimalAggregateValue money NULL,
    ValidityPeriod int NULL,
    DiscountValue decimal(3, 2) NOT NULL CHECK (
        DiscountValue >= 0
        AND DiscountValue <= 1
    ),
    startDate datetime NOT NULL DEFAULT getdate(),
    endDate datetime NULL,
    CONSTRAINT validDate CHECK(
        endDate IS NULL
        OR startDate < endDate
    ),
    CONSTRAINT DiscountsVar_pk PRIMARY KEY (VarID)
);

-- Table: Employees
CREATE TABLE Employees (
    PersonID int NOT NULL,
    CompanyID int NOT NULL,
    CONSTRAINT Employees_pk PRIMARY KEY (PersonID)
);

-- Table: IndividualClient
CREATE TABLE IndividualClient (
    ClientID int NOT NULL,
    PersonID int NOT NULL,
    CONSTRAINT IndividualClient_pk PRIMARY KEY (ClientID)
);

-- Table: Invoice
CREATE TABLE Invoice (
    InvoiceID int NOT NULL IDENTITY (1, 1),
    InvoiceNumber varchar(50) NOT NULL UNIQUE,
    InvoiceDate datetime NOT NULL,
    DueDate datetime NOT NULL,
    ClientID int NOT NULL,
    PaymentStatusID int NOT NULL,
    CONSTRAINT Invoice_pk PRIMARY KEY (InvoiceID)
);

-- Table: Menu
CREATE TABLE Menu (
    ID int NOT NULL IDENTITY (1, 1),
    MenuID int NOT NULL,
    Price money NOT NULL CHECK (Price > 0),
    startDate datetime NOT NULL DEFAULT getdate(),
    endDate datetime NULL,
    ProductID int NOT NULL,
    CONSTRAINT validDateMenu CHECK(
        (
            dateadd(DAY, 14, startDate) < endDate
            AND endDate IS NOT NULL
        )
        OR endDate IS NULL
    ),
    CONSTRAINT Menu_pk PRIMARY KEY (ID)
);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    OrderID int NOT NULL,
    Quantity int NOT NULL CHECK (Quantity > 0),
    ProductID int NOT NULL,
    CONSTRAINT OrderDetails_pk PRIMARY KEY (OrderID)
);

-- Table: Orders
CREATE TABLE Orders (
    OrderID int NOT NULL IDENTITY (1, 1),
    ClientID int NOT NULL,
    TakeawayID int NULL,
    ReservationID int NULL,
    PaymentStatusID int NOT NULL,
    staffID int NOT NULL,
    OrderSum money NOT NULL CHECK (OrderSum > 0),
    OrderDate datetime NOT NULL DEFAULT getdate(),
    OrderCompletionDate datetime NULL,
    OrderStatus varchar(15) NOT NULL CHECK (
        OrderStatus IN (
            'pending',
            'accepted',
            'completed',
            'denied',
            'picked',
            'cancelled'
        )
    ),
    CONSTRAINT validDateOrders CHECK (
        (OrderCompletionDate >= OrderDate)
        OR (OrderCompletionDate IS NULL)
    ),
    CONSTRAINT Orders_pk PRIMARY KEY (OrderID)
);

-- Table: OrdersTakeaways
CREATE TABLE OrdersTakeaways (
    TakeawaysID int NOT NULL IDENTITY (1, 1),
    PrefDate datetime NOT NULL CHECK (PrefDate >= getdate()),
    CONSTRAINT OrdersTakeaways_pk PRIMARY KEY (TakeawaysID)
);

-- Table: PaymentMethods
CREATE TABLE PaymentMethods (
    PaymentMethodID int NOT NULL IDENTITY (1, 1),
    PaymentName varchar(50) NOT NULL,
    CONSTRAINT PaymentMethods_pk PRIMARY KEY (PaymentMethodID)
);

-- Table: PaymentStatus
CREATE TABLE PaymentStatus (
    PaymentStatusID int NOT NULL IDENTITY (1, 1),
    PaymentStatusName varchar(50) NOT NULL DEFAULT 'Unpaid',
    PaymentMethodID int NOT NULL,
    CONSTRAINT PaymentStatus_pk PRIMARY KEY (PaymentStatusID)
);

-- Table: Person
CREATE TABLE Person (
    PersonID int NOT NULL IDENTITY (1, 1),
    LastName varchar(50) NOT NULL,
    FirstName varchar(70) NOT NULL,
    CONSTRAINT Person_pk PRIMARY KEY (PersonID)
);

-- Table: Products
CREATE TABLE Products (
    ProductID int NOT NULL IDENTITY (1, 1),
    CategoryID int NOT NULL,
    Name nvarchar(150) NOT NULL,
    Description nvarchar(150) NOT NULL DEFAULT 'brak opisu',
    IsAvailable bit NOT NULL DEFAULT 1,
    CONSTRAINT Products_pk PRIMARY KEY (ProductID)
);

-- Table: Reservation
CREATE TABLE Reservation (
    ReservationID int NOT NULL IDENTITY (1, 1),
    startDate datetime NOT NULL,
    endDate datetime NOT NULL,
    STATUS varchar(15) NOT NULL DEFAULT 'waiting',
    StaffID int NOT NULL,
    CONSTRAINT validStatus CHECK (
        STATUS IN (
            'pending',
            'accepted',
            'denied',
            'cancelled',
            'waiting'
        )
    ),
    CONSTRAINT validDateReservation CHECK(startDate < endDate),
    CONSTRAINT Reservation_pk PRIMARY KEY (ReservationID)
);

-- Table: ReservationCompany
CREATE TABLE ReservationCompany (
    ReservationID int NOT NULL,
    ClientID int NULL,
    PersonID int NULL,
    CONSTRAINT ReservationCompany_pk PRIMARY KEY (ReservationID)
);

-- Table: ReservationDetails
CREATE TABLE ReservationDetails (
    ReservationID int NOT NULL,
    TableID int NOT NULL,
    CONSTRAINT ReservationDetails_pk PRIMARY KEY (ReservationID)
);

-- Table: ReservationIndividual
CREATE TABLE ReservationIndividual (
    ReservationID int NOT NULL,
    ClientID int NOT NULL,
    PersonID int NOT NULL,
    CONSTRAINT ReservationIndividual_pk PRIMARY KEY (ReservationID)
);

-- Table: ReservationVar
CREATE TABLE ReservationVar (
    ReservationVarID int NOT NULL IDENTITY (1, 1),
    WZ int NOT NULL CHECK (WZ > 0),
    WK int NOT NULL CHECK (WK > 0),
    startDate datetime NOT NULL,
    endDate datetime NULL,
    CONSTRAINT validDateReservationVar CHECK(
        startDate < endDate
        OR endDate IS NULL
    ),
    CONSTRAINT ReservationVar_pk PRIMARY KEY (ReservationVarID)
);

-- Table: Staff
CREATE TABLE Staff (
    StaffID int NOT NULL IDENTITY (1, 1),
    LastName nvarchar(50) NOT NULL,
    FirstName nvarchar(70) NOT NULL,
    Position varchar(50) NOT NULL,
    Email varchar(100) NOT NULL UNIQUE CHECK(Email LIKE '%[@]%[.]%'),
    Phone varchar(14) NOT NULL UNIQUE CHECK(
        isnumeric(Phone) = 1
        AND len(Phone) >= 9
    ),
    AddressID int NOT NULL,
    CONSTRAINT Staff_pk PRIMARY KEY (StaffID)
);

-- Table: Tables
CREATE TABLE TABLES (
    TableID int NOT NULL,
    ChairAmount int NOT NULL CHECK (ChairAmount >= 2),
    isActive bit NOT NULL DEFAULT 1,
    CONSTRAINT Tables_pk PRIMARY KEY (TableID)
);

-- foreign keys
-- Reference: Address_Cities (table: Address)
ALTER TABLE
    Address
ADD
    CONSTRAINT Address_Cities FOREIGN KEY (CityID) REFERENCES Cities ON UPDATE CASCADE -- Reference: Clients_Address (table: Clients)
ALTER TABLE
    Clients
ADD
    CONSTRAINT Clients_Address FOREIGN KEY (AddressID) REFERENCES Address ON UPDATE CASCADE -- Reference: Clients_IndividualClient (table: IndividualClient)
ALTER TABLE
    IndividualClient
ADD
    CONSTRAINT Clients_IndividualClient FOREIGN KEY (ClientID) REFERENCES Clients ON UPDATE CASCADE -- Reference: Companies_Clients (table: Companies)
ALTER TABLE
    Companies
ADD
    CONSTRAINT Companies_Clients FOREIGN KEY (ClientID) REFERENCES Clients -- Reference: Discounts_DiscountsVar (table: Discounts)
ALTER TABLE
    Discounts
ADD
    CONSTRAINT Discounts_DiscountsVar FOREIGN KEY (VarID) REFERENCES DiscountsVar ON UPDATE CASCADE -- Reference: Discounts_IndividualClient (table: Discounts)
ALTER TABLE
    Discounts
ADD
    CONSTRAINT Discounts_IndividualClient FOREIGN KEY (ClientID) REFERENCES IndividualClient ON UPDATE CASCADE -- Reference: Employees_Companies (table: Employees)
ALTER TABLE
    Employees
ADD
    CONSTRAINT Employees_Companies FOREIGN KEY (CompanyID) REFERENCES Companies ON UPDATE CASCADE -- Reference: Employees_Person (table: Employees)
ALTER TABLE
    Employees
ADD
    CONSTRAINT Employees_Person FOREIGN KEY (PersonID) REFERENCES Person ON UPDATE CASCADE -- Reference: IndividualClient_Person (table: IndividualClient)
ALTER TABLE
    IndividualClient
ADD
    CONSTRAINT IndividualClient_Person FOREIGN KEY (PersonID) REFERENCES Person ON UPDATE CASCADE -- Reference: Invoice_Clients (table: Invoice)
ALTER TABLE
    Invoice
ADD
    CONSTRAINT Invoice_Clients FOREIGN KEY (ClientID) REFERENCES Clients ON UPDATE CASCADE -- Reference: Invoice_PaymentStatus (table: Invoice)
ALTER TABLE
    Invoice
ADD
    CONSTRAINT Invoice_PaymentStatus FOREIGN KEY (PaymentStatusID) REFERENCES PaymentStatus ON UPDATE CASCADE -- Reference: Menu_Products (table: Menu)
ALTER TABLE
    Menu
ADD
    CONSTRAINT Menu_Products FOREIGN KEY (ProductID) REFERENCES Products ON UPDATE CASCADE -- Reference: OrderDetails_Orders (table: OrderDetails)
ALTER TABLE
    OrderDetails
ADD
    CONSTRAINT OrderDetails_Orders FOREIGN KEY (OrderID) REFERENCES Orders ON UPDATE CASCADE -- Reference: OrderDetails_Products (table: OrderDetails)
ALTER TABLE
    OrderDetails
ADD
    CONSTRAINT OrderDetails_Products FOREIGN KEY (ProductID) REFERENCES Products ON UPDATE CASCADE -- Reference: Orders_Clients (table: Orders)
ALTER TABLE
    Orders
ADD
    CONSTRAINT Orders_Clients FOREIGN KEY (ClientID) REFERENCES Clients ON UPDATE CASCADE -- Reference: Orders_OrdersTakeaways (table: Orders)
ALTER TABLE
    Orders
ADD
    CONSTRAINT Orders_OrdersTakeaways FOREIGN KEY (TakeawayID) REFERENCES OrdersTakeaways ON UPDATE CASCADE -- Reference: Orders_PaymentStatus (table: Orders)
ALTER TABLE
    Orders
ADD
    CONSTRAINT Orders_PaymentStatus FOREIGN KEY (PaymentStatusID) REFERENCES PaymentStatus ON UPDATE CASCADE -- Reference: Orders_Reservation (table: Orders)
ALTER TABLE
    Orders
ADD
    CONSTRAINT Orders_Reservation FOREIGN KEY (ReservationID) REFERENCES Reservation ON UPDATE CASCADE -- Reference: Orders_staff (table: Orders)
ALTER TABLE
    Orders
ADD
    CONSTRAINT Orders_staff FOREIGN KEY (staffID) REFERENCES Staff ON UPDATE CASCADE -- Reference: PaymentStatus_PaymentMethods (table: PaymentStatus)
ALTER TABLE
    PaymentStatus
ADD
    CONSTRAINT PaymentStatus_PaymentMethods FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods ON UPDATE CASCADE -- Reference: Products_Category (table: Products)
ALTER TABLE
    Products
ADD
    CONSTRAINT Products_Category FOREIGN KEY (CategoryID) REFERENCES Category ON UPDATE CASCADE -- Reference: ReservationCompany_Companies (table: ReservationCompany)
ALTER TABLE
    ReservationCompany
ADD
    CONSTRAINT ReservationCompany_Companies FOREIGN KEY (ClientID) REFERENCES Companies ON UPDATE CASCADE -- Reference: ReservationDetails_ReservationCompany (table: ReservationDetails)
ALTER TABLE
    ReservationDetails
ADD
    CONSTRAINT ReservationDetails_ReservationCompany FOREIGN KEY (ReservationID) REFERENCES ReservationCompany ON UPDATE CASCADE -- Reference: ReservationDetails_ReservationIndividual (table: ReservationDetails)
ALTER TABLE
    ReservationDetails
ADD
    CONSTRAINT ReservationDetails_ReservationIndividual FOREIGN KEY (ReservationID) REFERENCES ReservationIndividual ON UPDATE CASCADE -- Reference: ReservationDetails_Tables (table: ReservationDetails)
ALTER TABLE
    ReservationDetails
ADD
    CONSTRAINT ReservationDetails_Tables FOREIGN KEY (TableID) REFERENCES TABLES ON UPDATE CASCADE -- Reference: Reservation_ReservationCompany (table: Reservation)
ALTER TABLE
    Reservation
ADD
    CONSTRAINT Reservation_ReservationCompany FOREIGN KEY (ReservationID) REFERENCES ReservationCompany -- Reference: Reservation_ReservationIndividual (table: Reservation)
ALTER TABLE
    Reservation
ADD
    CONSTRAINT Reservation_ReservationIndividual FOREIGN KEY (ReservationID) REFERENCES ReservationIndividual -- Reference: Reservation_Staff (table: Reservation)
ALTER TABLE
    Reservation
ADD
    CONSTRAINT Reservation_Staff FOREIGN KEY (StaffID) REFERENCES Staff -- Reference: Staff_Address (table: Staff)
ALTER TABLE
    Staff
ADD
    CONSTRAINT Staff_Address FOREIGN KEY (AddressID) REFERENCES Address (AddressID);

-- End of file.