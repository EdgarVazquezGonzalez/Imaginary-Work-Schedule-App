/* 
   Project 2 - Work Schedule Planner
   CS 4337

   This file assumes that another facts file has already been consulted.
   The facts file should contain:
   employee/1
   workstation/3
   workstation_idle/2
   avoid_workstation/2
   avoid_shift/2
*/


workstation_idle(_, _) :- fail.
avoid_workstation(_, _) :- fail.
avoid_shift(_, _) :- fail.


/* ---------------------------------------------------
   plan/1

   Main predicate. It creates a plan with three parts:
   morning schedule, evening schedule, and night schedule.
   --------------------------------------------------- */

plan(plan(Morning, Evening, Night)) :-
    findall(E, employee(E), Employees),

    make_shift(morning, Employees, EmployeesLeft1, Morning),
    make_shift(evening, EmployeesLeft1, EmployeesLeft2, Evening),
    make_shift(night, EmployeesLeft2, [], Night).

    /* ---------------------------------------------------
   make_shift/4

   make_shift(Shift, EmployeesBefore, EmployeesAfter, Schedule)

   This makes the schedule for one shift.
   --------------------------------------------------- */

make_shift(Shift, EmployeesBefore, EmployeesAfter, Schedule) :-
    get_open_workstations(Shift, Workstations),
    assign_workstations(Shift, Workstations, EmployeesBefore, EmployeesAfter, Schedule).


/* ---------------------------------------------------
   get_open_workstations/2

   Gets all workstations that are not idle during this shift.
   --------------------------------------------------- */

get_open_workstations(Shift, Workstations) :-
    findall(W,
        (
            workstation(W, _, _),
            \+ workstation_idle(W, Shift)
        ),
        Workstations
    ).


/* ---------------------------------------------------
   assign_workstations/5

   Goes through each workstation and assigns workers to it.
   --------------------------------------------------- */


    
