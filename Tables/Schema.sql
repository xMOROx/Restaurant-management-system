
-- tables
-- Table: Address
CREATE TABLE Address (
    AddressID int  NOT NULL IDENTITY (1,1),
    CityID char(3)  NOT NULL,
    street nvarchar(70)  NOT NULL,
    LocalNr varchar(10)  NOT NULL check(localNr like '[0-9]%'),
    PostalCode char(6)  NOT NULL check(PostalCode like '[0-9][0-9]-[0-9][0-9][0-9]'),
    CONSTRAINT Address_pk PRIMARY KEY  (AddressID)
);

-- Table: Category
CREATE TABLE Category (
    CategoryID int  NOT NULL IDENTITY (1,1),
    CategoryName nvarchar(50)  NOT NULL,
    Description nvarchar(150)  NOT NULL,
    CONSTRAINT Category_pk PRIMARY KEY  (CategoryID)
);

-- Table: Cities
CREATE TABLE Cities (
    CityID char(3)  NOT NULL ,
    CityName nvarchar(35)  NOT NULL,
    CONSTRAINT Cities_pk PRIMARY KEY  (CityID)
);

-- Table: Clients
CREATE TABLE Clients (
    ClientID int  NOT NULL IDENTITY (1,1),
    AddressID int  NOT NULL,
    Phone varchar(14)  NOT NULL UNIQUE check (isnumeric(Phone) = 1 and len(Phone) >= 9),
    Email varchar(100)  NOT NULL UNIQUE check( Email like '%[@]%[.]%'),
    CONSTRAINT Clients_pk PRIMARY KEY  (ClientID)
);

-- Table: Companies
CREATE TABLE Companies (
    ClientID int  NOT NULL IDENTITY (1,1),
    CompanyName nvarchar(50)  NOT NULL UNIQUE,
    NIP char(10)  NOT NULL UNIQUE check(NIP like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    KRS char(10)  NULL UNIQUE check(KRS like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    Regon char(9)  NULL UNIQUE check(Regon like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT Companies_pk PRIMARY KEY  (ClientID)
);

-- Table: Discounts
CREATE TABLE Discounts (
    DiscountID int  NOT NULL IDENTITY (1,1),
    ClientID int  NOT NULL,
    VarID int  NOT NULL,
    AppliedDate datetime  NOT NULL ,
    CONSTRAINT Discounts_pk PRIMARY KEY  (DiscountID)
);

-- Table: DiscountsVar
CREATE TABLE DiscountsVar (
    VarID int  NOT NULL IDENTITY (1,1),
    DiscountType char(9)  NOT NULL check (DiscountType in ('Permanent', 'Temporary')),
    MinimalOrders int  NULL,
    MinimalAggregateValue money  NULL,
    ValidityPeriod int  NULL,
    DiscountValue decimal(3,2)  NOT NULL CHECK ( DiscountValue >= 0 and DiscountValue <= 1 ),
    startDate datetime  NOT NULL DEFAULT getdate(),
    endDate datetime  NULL,
    CONSTRAINT validDate check(endDate IS NULL or startDate < endDate),
    CONSTRAINT DiscountsVar_pk PRIMARY KEY  (VarID)
);

-- Table: Employees
CREATE TABLE Employees (
    PersonID int  NOT NULL,
    CompanyID int  NOT NULL,
    CONSTRAINT Employees_pk PRIMARY KEY  (PersonID)
);

-- Table: IndividualClient
CREATE TABLE IndividualClient (
    ClientID int  NOT NULL,
    PersonID int  NOT NULL,
    CONSTRAINT IndividualClient_pk PRIMARY KEY  (ClientID)
);

-- Table: Invoice
CREATE TABLE Invoice (
    InvoiceID int  NOT NULL IDENTITY (1,1),
    InvoiceNumber varchar(50)  NOT NULL UNIQUE,
    InvoiceDate datetime  NOT NULL,
    DueDate datetime  NOT NULL,
    ClientID int  NOT NULL,
    PaymentStatusID int  NOT NULL,
    CONSTRAINT Invoice_pk PRIMARY KEY  (InvoiceID)
);

-- Table: Menu
CREATE TABLE Menu (
    MenuID int  NOT NULL IDENTITY (1,1),
    Price money  NOT NULL check ( Price > 0 ),
    startDate datetime  NOT NULL default getdate(),
    endDate datetime  NOT NULL ,
    ProductID int  NOT NULL,
    CONSTRAINT validDateMenu check(startDate < endDate),
    CONSTRAINT Menu_pk PRIMARY KEY  (MenuID)
);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    OrderID int  NOT NULL,
    Quantity int  NOT NULL check ( Quantity > 0 ),
    ProductID int  NOT NULL,
    CONSTRAINT OrderDetails_pk PRIMARY KEY  (OrderID)
);

-- Table: Orders
CREATE TABLE Orders (
    OrderID int  NOT NULL IDENTITY (1,1),
    ClientID int  NOT NULL,
    TakeawayID int  NULL,
    ReservationID int  NULL,
    PaymentStatusID int  NOT NULL,
    staffID int  NOT NULL,
    OrderSum money  NOT NULL check ( OrderSum > 0 ),
    OrderDate datetime  NOT NULL default getdate(),
    OrderCompletionDate datetime  NOT NULL ,
    Picked bit  NOT NULL,
    CONSTRAINT validDateOrders check ( OrderCompletionDate >= OrderDate ),
    CONSTRAINT Orders_pk PRIMARY KEY  (OrderID)
);

-- Table: OrdersTakeaways
CREATE TABLE OrdersTakeaways (
    TakeawaysID int  NOT NULL IDENTITY (1,1),
    PrefDate datetime  NOT NULL check (PrefDate > getdate()),
    CONSTRAINT OrdersTakeaways_pk PRIMARY KEY  (TakeawaysID)
);

-- Table: PaymentMethods
CREATE TABLE PaymentMethods (
    PaymentMethodID int  NOT NULL IDENTITY (1,1),
    PaymentName varchar(50)  NOT NULL,
    CONSTRAINT PaymentMethods_pk PRIMARY KEY  (PaymentMethodID)
);

-- Table: PaymentStatus
CREATE TABLE PaymentStatus (
    PaymentStatusID int  NOT NULL IDENTITY (1,1),
    PaymentStatusName varchar(50)  NOT NULL,
    PaymentMethodID int  NOT NULL,
    CONSTRAINT PaymentStatus_pk PRIMARY KEY  (PaymentStatusID)
);

-- Table: Person
CREATE TABLE Person (
    PersonID int  NOT NULL IDENTITY (1,1),
    LastName varchar(50)  NOT NULL,
    FirstName varchar(70)  NOT NULL,
    CONSTRAINT Person_pk PRIMARY KEY  (PersonID)
);

-- Table: Products
CREATE TABLE Products (
    ProductID int  NOT NULL IDENTITY (1,1),
    CategoryID int  NOT NULL,
    Name nvarchar(50)  NOT NULL,
    Description nvarchar(150)  NOT NULL default 'brak opisu' ,
    CONSTRAINT Products_pk PRIMARY KEY  (ProductID)
);

-- Table: Reservation
CREATE TABLE Reservation (
    ReservationID int  NOT NULL  IDENTITY (1,1),
    startDate datetime  NOT NULL,
    endDate datetime  NOT NULL ,
    Status bit  NOT NULL,
    StaffID int  NOT NULL,
    CONSTRAINT validDateReservation  check(startDate < endDate),
    CONSTRAINT Reservation_pk PRIMARY KEY  (ReservationID)
);

-- Table: ReservationCompany
CREATE TABLE ReservationCompany (
    ReservationID int  NOT NULL,
    ClientID int  NULL,
    PersonID int  NULL,
    CONSTRAINT ReservationCompany_pk PRIMARY KEY  (ReservationID)
);

-- Table: ReservationDetails
CREATE TABLE ReservationDetails (
    ReservationID int  NOT NULL,
    TableID int  NOT NULL,
    CONSTRAINT ReservationDetails_pk PRIMARY KEY  (ReservationID)
);

-- Table: ReservationIndividual
CREATE TABLE ReservationIndividual (
    ReservationID int  NOT NULL,
    ClientID int  NOT NULL,
    PersonID int  NOT NULL,
    CONSTRAINT ReservationIndividual_pk PRIMARY KEY  (ReservationID)
);

-- Table: ReservationVar
CREATE TABLE ReservationVar (
    ReservationVarID int  NOT NULL IDENTITY (1,1),
    WZ int  NOT NULL check ( WZ > 0 ),
    WK int  NOT NULL check (WK > 0),
    startDate datetime  NOT NULL,
    endDate datetime  NULL,
    CONSTRAINT validDateReservationVar check(startDate < endDate or endDate is NULL),
    CONSTRAINT ReservationVar_pk PRIMARY KEY  (ReservationVarID)
);

-- Table: Staff
CREATE TABLE Staff (
    StaffID int  NOT NULL IDENTITY (1,1),
    LastName nvarchar(50)  NOT NULL,
    FirstName nvarchar(70)  NOT NULL,
    Position varchar(50)  NOT NULL,
    Email varchar(100)  NOT NULL UNIQUE check( Email like '%[@]%[.]%'),
    Phone varchar(14)  NOT NULL UNIQUE check( isnumeric(Phone) = 1 and len(Phone) >= 9),
    AddressID int  NOT NULL ,
    CONSTRAINT Staff_pk PRIMARY KEY  (StaffID)
);

-- Table: Tables
CREATE TABLE Tables (
    TableID int  NOT NULL,
    ChairAmount int  NOT NULL check (ChairAmount >= 2),
    isActive bit  NOT NULL default 1,
    CONSTRAINT Tables_pk PRIMARY KEY  (TableID)
);

-- foreign keys
-- Reference: Address_Cities (table: Address)
ALTER TABLE Address ADD CONSTRAINT Address_Cities
    FOREIGN KEY (CityID)
    REFERENCES Cities (CityID);

-- Reference: Clients_Address (table: Clients)
ALTER TABLE Clients ADD CONSTRAINT Clients_Address
    FOREIGN KEY (AddressID)
    REFERENCES Address (AddressID);

-- Reference: Clients_IndividualClient (table: IndividualClient)
ALTER TABLE IndividualClient ADD CONSTRAINT Clients_IndividualClient
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: Companies_Clients (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Companies_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: Discounts_DiscountsVar (table: Discounts)
ALTER TABLE Discounts ADD CONSTRAINT Discounts_DiscountsVar
    FOREIGN KEY (VarID)
    REFERENCES DiscountsVar (VarID);

-- Reference: Discounts_IndividualClient (table: Discounts)
ALTER TABLE Discounts ADD CONSTRAINT Discounts_IndividualClient
    FOREIGN KEY (ClientID)
    REFERENCES IndividualClient (ClientID);

-- Reference: Employees_Companies (table: Employees)
ALTER TABLE Employees ADD CONSTRAINT Employees_Companies
    FOREIGN KEY (CompanyID)
    REFERENCES Companies (ClientID);

-- Reference: Employees_Person (table: Employees)
ALTER TABLE Employees ADD CONSTRAINT Employees_Person
    FOREIGN KEY (PersonID)
    REFERENCES Person (PersonID);

-- Reference: IndividualClient_Person (table: IndividualClient)
ALTER TABLE IndividualClient ADD CONSTRAINT IndividualClient_Person
    FOREIGN KEY (PersonID)
    REFERENCES Person (PersonID);

-- Reference: Invoice_Clients (table: Invoice)
ALTER TABLE Invoice ADD CONSTRAINT Invoice_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: Invoice_PaymentStatus (table: Invoice)
ALTER TABLE Invoice ADD CONSTRAINT Invoice_PaymentStatus
    FOREIGN KEY (PaymentStatusID)
    REFERENCES PaymentStatus (PaymentStatusID);

-- Reference: Menu_Products (table: Menu)
ALTER TABLE Menu ADD CONSTRAINT Menu_Products
    FOREIGN KEY (ProductID)
    REFERENCES Products (ProductID);

-- Reference: OrderDetails_Orders (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_Orders
    FOREIGN KEY (OrderID)
    REFERENCES Orders (OrderID);

-- Reference: OrderDetails_Products (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_Products
    FOREIGN KEY (ProductID)
    REFERENCES Products (ProductID);

-- Reference: Orders_Clients (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: Orders_OrdersTakeaways (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_OrdersTakeaways
    FOREIGN KEY (TakeawayID)
    REFERENCES OrdersTakeaways (TakeawaysID);

-- Reference: Orders_PaymentStatus (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_PaymentStatus
    FOREIGN KEY (PaymentStatusID)
    REFERENCES PaymentStatus (PaymentStatusID);

-- Reference: Orders_Reservation (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_Reservation
    FOREIGN KEY (ReservationID)
    REFERENCES Reservation (ReservationID);

-- Reference: Orders_staff (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_staff
    FOREIGN KEY (staffID)
    REFERENCES Staff (StaffID);

-- Reference: PaymentStatus_PaymentMethods (table: PaymentStatus)
ALTER TABLE PaymentStatus ADD CONSTRAINT PaymentStatus_PaymentMethods
    FOREIGN KEY (PaymentMethodID)
    REFERENCES PaymentMethods (PaymentMethodID);

-- Reference: Products_Category (table: Products)
ALTER TABLE Products ADD CONSTRAINT Products_Category
    FOREIGN KEY (CategoryID)
    REFERENCES Category (CategoryID);

-- Reference: ReservationCompany_Companies (table: ReservationCompany)
ALTER TABLE ReservationCompany ADD CONSTRAINT ReservationCompany_Companies
    FOREIGN KEY (ClientID)
    REFERENCES Companies (ClientID);

-- Reference: ReservationDetails_ReservationCompany (table: ReservationDetails)
ALTER TABLE ReservationDetails ADD CONSTRAINT ReservationDetails_ReservationCompany
    FOREIGN KEY (ReservationID)
    REFERENCES ReservationCompany (ReservationID);

-- Reference: ReservationDetails_ReservationIndividual (table: ReservationDetails)
ALTER TABLE ReservationDetails ADD CONSTRAINT ReservationDetails_ReservationIndividual
    FOREIGN KEY (ReservationID)
    REFERENCES ReservationIndividual (ReservationID);

-- Reference: ReservationDetails_Tables (table: ReservationDetails)
ALTER TABLE ReservationDetails ADD CONSTRAINT ReservationDetails_Tables
    FOREIGN KEY (TableID)
    REFERENCES Tables (TableID);

-- Reference: Reservation_ReservationCompany (table: Reservation)
ALTER TABLE Reservation ADD CONSTRAINT Reservation_ReservationCompany
    FOREIGN KEY (ReservationID)
    REFERENCES ReservationCompany (ReservationID);

-- Reference: Reservation_ReservationIndividual (table: Reservation)
ALTER TABLE Reservation ADD CONSTRAINT Reservation_ReservationIndividual
    FOREIGN KEY (ReservationID)
    REFERENCES ReservationIndividual (ReservationID);

-- Reference: Reservation_Staff (table: Reservation)
ALTER TABLE Reservation ADD CONSTRAINT Reservation_Staff
    FOREIGN KEY (StaffID)
    REFERENCES Staff (StaffID);

-- Reference: Staff_Address (table: Staff)
ALTER TABLE Staff ADD CONSTRAINT Staff_Address
    FOREIGN KEY (AddressID)
    REFERENCES Address (AddressID);

-- End of file.

