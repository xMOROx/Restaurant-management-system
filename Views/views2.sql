create view dbo.Waiter as
    select FirstName + ' ' + LastName as Name, OrderID as id
    from Staff
             join Orders O on Staff.StaffID = O.staffID
    where Position = 'waiter'
       or Position = 'waitress';

create view dbo.AllTakeaways as
    select TakeawayID,
           PrefDate,
           OrderID,
           ClientID,
           PaymentStatusID,
           staffID,
           OrderSum,
           OrderDate,
           OrderCompletionDate,
           OrderStatus
    from OrdersTakeaways
             join Orders O on OrdersTakeaways.TakeawaysID = O.TakeawayID;

create view OrdersToPrepare as
    select *
    from Orders join OrdersTakeaways OT on Orders.TakeawayID = OT.TakeawaysID
    where OrderCompletionDate is null

create view SeeFood as
    select count(OD.OrderID)
    from Orders join OrderDetails OD on Orders.OrderID = OD.OrderID join Products P on P.ProductID = OD.ProductID join Category C on C.CategoryID = P.CategoryID
    where CategoryName='sea food' and OrderCompletionDate is null
    group by CategoryName
    union
    select OD.OrderID
    from Orders join OrderDetails OD on Orders.OrderID = OD.OrderID join Products P on P.ProductID = OD.ProductID join Category C on C.CategoryID = P.CategoryID
    where CategoryName='sea food' and OrderCompletionDate is null

create view OrdersNotYetPickedByClient as
    select ClientID,TakeawaysID,OrderID
    from Clients join Orders O on Clients.ClientID = O.ClientID join OrdersTakeaways OT on OT.TakeawaysID = O.TakeawayID
    where O.Picked=FALSE
    order by ClientID