# Project Overview 5/7/2026 1:00 pm 
Goal : Prolog program will simulate a backend for an imaginary work scheduling app.
The program uses facts about employees, workstations, workstation requirements, and
employee restrictions.

The main predicate is 

plan(Plan)

Plab should unift a structure with the format
plan(Morning, Evening, Night)

Each shift contains a list of workstation assignments. Each assignment has the following format
workstation(Station, Employees)

The following rules must be followed
- every employee must be assigned to only one workstation during one shift
- each workstation must have reached its minimum number of employees
- each workstation must not exceed its maximum number of employees
- idle workstations should not appear in the schedule for that shift
- employees should not be assigned to workstations that they are supposed to avoid
- employees should not be assigned to shifts that they are supposed to avoid
- if no valid schedue can be made, /plan fails

## 5/8/2026 9:56 pm
Testing was an issue because my path destination was messsed up so I had to troubleshoot for that. I am now able to compile and test. Issue that I am running into is 
infinite loops. This can be fixed if I add the once() function into the query. I could also edit the testing.pl file but not sure if I am allowed. When implementing once() into query lines my outputs do match the output examples. 

  
