create view dbo.Waiter as
    select FirstName + ' ' + LastName as Name, OrderID as id
    from Staff
         join Orders O on Staff.StaffID = O.staffID
    where Position = 'waiter'
        or Position = 'waitress';
