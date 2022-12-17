create view dbo.Waiter as
    select FirstName + ' ' + LastName as Name, OrderID as id
    from Staff
             join Orders O on Staff.StaffID = O.staffID
    where Position = 'waiter'
       or Position = 'waitress';

create view dbo.Takeaways as
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

