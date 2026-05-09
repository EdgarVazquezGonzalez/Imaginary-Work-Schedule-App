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

   No cut is used here because plan/1 should be able to
   generate more than one valid schedule through backtracking.
   --------------------------------------------------- */

plan(plan(Morning, Evening, Night)) :-
    findall(E, employee(E), Employees),

    make_shift(morning, [evening, night], Employees, EmployeesLeft1, Morning),
    make_shift(evening, [night], EmployeesLeft1, EmployeesLeft2, Evening),
    make_shift(night, [], EmployeesLeft2, [], Night),!.


/* ---------------------------------------------------
   make_shift/5

   make_shift(Shift, FutureShifts, EmployeesBefore, EmployeesAfter, Schedule)

   This makes the schedule for one shift. FutureShifts is used
   to check whether the remaining employees can still fit in
   the shifts that come later.
   --------------------------------------------------- */

make_shift(Shift, FutureShifts, EmployeesBefore, EmployeesAfter, Schedule) :-
    get_open_workstations(Shift, Workstations),
    valid_workstation_requirements(Workstations),
    assign_workstations(Shift, Workstations, EmployeesBefore, EmployeesAfter, Schedule),
    employees_can_fit_future(FutureShifts, EmployeesAfter).


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
   employees_can_fit_future/2

   Checks that the employees left after a shift can still fit
   into the remaining future shifts.

   This helps avoid long searches where Prolog leaves too many
   employees for a later shift that does not have enough capacity.
   --------------------------------------------------- */

employees_can_fit_future([], EmployeesLeft) :-
    length(EmployeesLeft, 0).

employees_can_fit_future(FutureShifts, EmployeesLeft) :-
    FutureShifts \= [],
    length(EmployeesLeft, Count),
    total_max_capacity(FutureShifts, MaxCapacity),
    Count =< MaxCapacity.


/* ---------------------------------------------------
   total_max_capacity/2

   Adds up the maximum employee capacity for a list of shifts.
   --------------------------------------------------- */

total_max_capacity([], 0).

total_max_capacity([Shift | Rest], Total) :-
    get_open_workstations(Shift, Workstations),
    shift_max_capacity(Workstations, ShiftMax),
    total_max_capacity(Rest, RestMax),
    Total is ShiftMax + RestMax.


/* ---------------------------------------------------
   shift_max_capacity/2

   Adds up the max values for all active workstations in one shift.
   --------------------------------------------------- */

shift_max_capacity([], 0).

shift_max_capacity([W | Rest], Total) :-
    workstation(W, _, Max),
    shift_max_capacity(Rest, RestTotal),
    Total is Max + RestTotal.


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
