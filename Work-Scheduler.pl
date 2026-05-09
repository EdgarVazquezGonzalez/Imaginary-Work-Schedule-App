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


/* ---------------------------------------------------
   Helper predicates for optional facts

   These are used instead of writing fallback rules like:
   workstation_idle(_, _) :- fail.

   The fallback rules caused problems because they could interfere
   with the actual input facts.
   --------------------------------------------------- */

is_idle(Workstation, Shift) :-
    current_predicate(workstation_idle/2),
    workstation_idle(Workstation, Shift).

avoids_station(Employee, Workstation) :-
    current_predicate(avoid_workstation/2),
    avoid_workstation(Employee, Workstation).

avoids_shift(Employee, Shift) :-
    current_predicate(avoid_shift/2),
    avoid_shift(Employee, Shift).


/* ---------------------------------------------------
   plan/1

   Main predicate. It creates a plan with three parts:
   morning schedule, evening schedule, and night schedule.
   --------------------------------------------------- */

plan(plan(Morning, Evening, Night)) :-
    findall(E, employee(E), Employees),

    make_shift(morning, Employees, EmployeesLeft1, Morning),
    make_shift(evening, EmployeesLeft1, EmployeesLeft2, Evening),
    make_shift(night, EmployeesLeft2, [], Night),

    % Cut is used so Prolog stops after finding one valid schedule.
    !.


/* ---------------------------------------------------
   make_shift/4

   make_shift(Shift, EmployeesBefore, EmployeesAfter, Schedule)

   This makes the schedule for one shift.
   --------------------------------------------------- */

make_shift(Shift, EmployeesBefore, EmployeesAfter, Schedule) :-
    get_open_workstations(Shift, Workstations),
    valid_workstation_requirements(Workstations),
    assign_workstations(Shift, Workstations, EmployeesBefore, EmployeesAfter, Schedule).


/* ---------------------------------------------------
   get_open_workstations/2

   Gets all workstations that are not idle during this shift.
   --------------------------------------------------- */

get_open_workstations(Shift, Workstations) :-
    findall(W,
        (
            workstation(W, _, _),
            \+ is_idle(W, Shift)
        ),
        Workstations
    ).


/* ---------------------------------------------------
   valid_workstation_requirements/1

   Checks that every active workstation has a possible
   employee range.

   Example:
   workstation(5, 3, 1) is impossible because Min > Max.
   --------------------------------------------------- */

valid_workstation_requirements([]).

valid_workstation_requirements([W | Rest]) :-
    workstation(W, Min, Max),
    Min =< Max,
    valid_workstation_requirements(Rest).


/* ---------------------------------------------------
   assign_workstations/5

   Goes through each workstation and assigns workers to it.
   --------------------------------------------------- */

assign_workstations(_, [], Employees, Employees, []).

assign_workstations(
    Shift,
    [W | Rest],
    EmployeesBefore,
    EmployeesAfter,
    [workstation(W, WorkersForThisStation) | RestOfSchedule]
) :-
    workstation(W, Min, Max),

    pick_employees(
        W,
        Shift,
        Min,
        Max,
        EmployeesBefore,
        WorkersForThisStation,
        EmployeesLeft
    ),

    assign_workstations(
        Shift,
        Rest,
        EmployeesLeft,
        EmployeesAfter,
        RestOfSchedule
    ).


/* ---------------------------------------------------
   pick_employees/7

   Picks a valid number of employees for one workstation.
   The number picked has to be between Min and Max.
   --------------------------------------------------- */

pick_employees(W, Shift, Min, Max, EmployeesBefore, PickedEmployees, EmployeesLeft) :-
    between(Min, Max, NumberNeeded),
    pick_n_employees(
        NumberNeeded,
        W,
        Shift,
        EmployeesBefore,
        PickedEmployees,
        EmployeesLeft
    ).


/* ---------------------------------------------------
   pick_n_employees/6

   Picks exactly N employees from the list.
   Employees who are not picked stay in the remaining list.
   --------------------------------------------------- */

pick_n_employees(0, _, _, Employees, [], Employees).

pick_n_employees(N, W, Shift, [E | Rest], [E | PickedRest], EmployeesLeft) :-
    N > 0,
    can_work(E, W, Shift),
    N2 is N - 1,
    pick_n_employees(N2, W, Shift, Rest, PickedRest, EmployeesLeft).

pick_n_employees(N, W, Shift, [E | Rest], PickedEmployees, [E | EmployeesLeft]) :-
    N > 0,
    pick_n_employees(N, W, Shift, Rest, PickedEmployees, EmployeesLeft).


/* ---------------------------------------------------
   can_work/3

   Checks if an employee is allowed to work at a workstation
   during a certain shift.
   --------------------------------------------------- */

can_work(Employee, Workstation, Shift) :-
    \+ avoids_station(Employee, Workstation),
    \+ avoids_shift(Employee, Shift).
