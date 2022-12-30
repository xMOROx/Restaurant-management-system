
-- tables
-- Table: Address
CREATE TABLE Address (
    AddressID int  NOT NULL IDENTITY (1,1),
    CityID INT NOT NULL,
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
    CityID INT  NOT NULL IDENTITY (1,1),
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
    ClientID int  NOT NULL,
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
    isUsed bit NULL default 0,
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
    ID int NOT NULL IDENTITY (1,1) ,
    MenuID int  NOT NULL ,
    Price money  NOT NULL check ( Price > 0 ),
    startDate datetime  NOT NULL default getdate(),
    endDate datetime NULL ,
    ProductID int  NOT NULL,
    CONSTRAINT validDateMenu check((dateadd(day, 14 ,startDate) < endDate and endDate is not null) or endDate is null),
    CONSTRAINT Menu_pk PRIMARY KEY  (ID)
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
    OrderCompletionDate datetime  NULL ,
    OrderStatus varchar(15) NOT NULL check (OrderStatus in ('pending', 'accepted', 'completed', 'denied', 'picked', 'cancelled')),
    CONSTRAINT validDateOrders check ( (OrderCompletionDate >= OrderDate)  or (OrderCompletionDate is null)),
    CONSTRAINT Orders_pk PRIMARY KEY  (OrderID)
);

-- Table: OrdersTakeaways
CREATE TABLE OrdersTakeaways (
    TakeawaysID int  NOT NULL IDENTITY (1,1),
    PrefDate datetime  NOT NULL check (PrefDate >= getdate()),
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
    PaymentStatusName varchar(50)  NOT NULL default 'Unpaid',
    PaymentMethodID int  NOT NULL,
    CONSTRAINT PaymentStatus_pk PRIMARY KEY  (PaymentStatusID)
);

-- Table: Person
CREATE TABLE Person (
    PersonID int  NOT NULL,
    LastName varchar(50)  NOT NULL,
    FirstName varchar(70)  NOT NULL,
    CONSTRAINT Person_pk PRIMARY KEY  (PersonID)
);

-- Table: Products
CREATE TABLE Products (
    ProductID int  NOT NULL IDENTITY (1,1),
    CategoryID int  NOT NULL,
    Name nvarchar(150)  NOT NULL,
    Description nvarchar(150)  NOT NULL default 'brak opisu',
    IsAvailable bit NOT NULL default 1,
    CONSTRAINT Products_pk PRIMARY KEY  (ProductID)
);

-- Table: Reservation
CREATE TABLE Reservation (
    ReservationID int  NOT NULL  IDENTITY (1,1),
    startDate datetime  NOT NULL,
    endDate datetime  NOT NULL ,
    Status varchar(15)  NOT NULL default 'waiting',
    StaffID int  NOT NULL,
    constraint validStatus check (Status in ('pending', 'accepted', 'denied', 'cancelled', 'waiting')),
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
alter table Address
    add constraint Address_Cities
        foreign key (CityID) references Cities
            on update cascade

-- Reference: Clients_Address (table: Clients)
alter table Clients
    add constraint Clients_Address
        foreign key (AddressID) references Address
            on update cascade

-- Reference: Clients_IndividualClient (table: IndividualClient)
alter table IndividualClient
    add constraint Clients_IndividualClient
        foreign key (ClientID) references Clients
            on update cascade

-- Reference: Companies_Clients (table: Companies)
alter table Companies
    add constraint Companies_Clients
        foreign key (ClientID) references Clients

-- Reference: Discounts_DiscountsVar (table: Discounts)
alter table Discounts
    add constraint Discounts_DiscountsVar
        foreign key (VarID) references DiscountsVar
            on update cascade

-- Reference: Discounts_IndividualClient (table: Discounts)
alter table Discounts
    add constraint Discounts_IndividualClient
        foreign key (ClientID) references IndividualClient
            on update cascade

-- Reference: Employees_Companies (table: Employees)
alter table Employees
    add constraint Employees_Companies
        foreign key (CompanyID) references Companies
            on update cascade

-- Reference: Employees_Person (table: Employees)
alter table Employees
    add constraint Employees_Person
        foreign key (PersonID) references Person
            on update cascade

-- Reference: IndividualClient_Person (table: IndividualClient)
alter table IndividualClient
    add constraint IndividualClient_Person
        foreign key (PersonID) references Person
            on update cascade

-- Reference: Invoice_Clients (table: Invoice)
alter table Invoice
    add constraint Invoice_Clients
        foreign key (ClientID) references Clients
            on update cascade

-- Reference: Invoice_PaymentStatus (table: Invoice)
alter table Invoice
    add constraint Invoice_PaymentStatus
        foreign key (PaymentStatusID) references PaymentStatus
            on update cascade

-- Reference: Menu_Products (table: Menu)
alter table Menu
    add constraint Menu_Products
        foreign key (ProductID) references Products
            on update cascade

-- Reference: OrderDetails_Orders (table: OrderDetails)
alter table OrderDetails
    add constraint OrderDetails_Orders
        foreign key (OrderID) references Orders
            on update cascade

-- Reference: OrderDetails_Products (table: OrderDetails)
alter table OrderDetails
    add constraint OrderDetails_Products
        foreign key (ProductID) references Products
            on update cascade

-- Reference: Orders_Clients (table: Orders)
alter table Orders
    add constraint Orders_Clients
        foreign key (ClientID) references Clients
            on update cascade

-- Reference: Orders_OrdersTakeaways (table: Orders)
alter table Orders
    add constraint Orders_OrdersTakeaways
        foreign key (TakeawayID) references OrdersTakeaways
            on update cascade

-- Reference: Orders_PaymentStatus (table: Orders)
alter table Orders
    add constraint Orders_PaymentStatus
        foreign key (PaymentStatusID) references PaymentStatus
            on update cascade

-- Reference: Orders_Reservation (table: Orders)
alter table Orders
    add constraint Orders_Reservation
        foreign key (ReservationID) references Reservation
            on update cascade

-- Reference: Orders_staff (table: Orders)
alter table Orders
    add constraint Orders_staff
        foreign key (staffID) references Staff
            on update cascade

-- Reference: PaymentStatus_PaymentMethods (table: PaymentStatus)
alter table PaymentStatus
    add constraint PaymentStatus_PaymentMethods
        foreign key (PaymentMethodID) references PaymentMethods
            on update cascade

-- Reference: Products_Category (table: Products)
alter table Products
    add constraint Products_Category
        foreign key (CategoryID) references Category
            on update cascade

-- Reference: ReservationCompany_Companies (table: ReservationCompany)
alter table ReservationCompany
    add constraint ReservationCompany_Companies
        foreign key (ClientID) references Companies
            on update cascade

-- Reference: ReservationDetails_ReservationCompany (table: ReservationDetails)
alter table ReservationDetails
    add constraint ReservationDetails_ReservationCompany
        foreign key (ReservationID) references ReservationCompany
            on update cascade

-- Reference: ReservationDetails_ReservationIndividual (table: ReservationDetails)
alter table ReservationDetails
    add constraint ReservationDetails_ReservationIndividual
        foreign key (ReservationID) references ReservationIndividual
            on update cascade

-- Reference: ReservationDetails_Tables (table: ReservationDetails)
alter table ReservationDetails
    add constraint ReservationDetails_Tables
        foreign key (TableID) references Tables
            on update cascade

-- Reference: Reservation_ReservationCompany (table: Reservation)
alter table Reservation
    add constraint Reservation_ReservationCompany
        foreign key (ReservationID) references ReservationCompany

-- Reference: Reservation_ReservationIndividual (table: Reservation)
alter table Reservation
    add constraint Reservation_ReservationIndividual
        foreign key (ReservationID) references ReservationIndividual

-- Reference: Reservation_Staff (table: Reservation)
alter table Reservation
    add constraint Reservation_Staff
        foreign key (StaffID) references Staff

-- Reference: Staff_Address (table: Staff)
ALTER TABLE Staff ADD CONSTRAINT Staff_Address
    FOREIGN KEY (AddressID)
    REFERENCES Address (AddressID);

-- End of file.

