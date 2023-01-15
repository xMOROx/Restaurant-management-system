CREATE INDEX 'Index_ClientID'
    on Clients (ClientID)

CREATE INDEX 'Index_Clients_Phone'
    on Clients (Phone)

CREATE INDEX 'Index_Clients_Email'
    on Clients (Email)

CREATE INDEX 'Index_Staff_Email'
    on Staff (Email)

CREATE INDEX 'Index_Staff_Phone'
    on Staff (Phone)

CREATE INDEX 'Index_PersonID'
    on Person (PersonID)

CREATE INDEX 'Index_PaymentName'
    on PaymentMethods (PaymentName)

CREATE INDEX 'Index_PaymentStatusID'
    on PaymentStatus (PaymentStatusID)

CREATE INDEX 'Index_InvoiceID'
    on Invoice (InvoiceID)

CREATE INDEX 'Index_InvoiceNumber'
    on Invoice (InvoiceNumber)

CREATE INDEX 'Index_MenuID'
    on Menu (MenuID)

CREATE INDEX 'Index_Price'
    on Menu (Price)

CREATE INDEX 'Index_CategoryID'
    on Category (CategoryID)

CREATE INDEX 'Index_ProductID'
    on Products (ProductID)

CREATE INDEX 'Index_Name'
    on Products (Name)

CREATE INDEX 'Index_DiscountID'
    on Discounts (DiscountID)

CREATE INDEX 'Index_ReservationID'
    on Reservation (ReservationID)

CREATE INDEX 'Index_TableID'
    on Tables (TableID)

CREATE INDEX 'Index_AddressID'
    on Address (AddressID)

CREATE INDEX 'Index_CityID'
    on Cities (CityID)

CREATE INDEX 'Index_DiscountsVar_Information'
    on DiscountsVar (discounttype, minimalorders, minimalaggregatevalue, validityperiod, discountvalue, startdate,
                     enddate)




