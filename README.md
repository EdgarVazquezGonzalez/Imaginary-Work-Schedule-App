# Imaginary-Work-Schedule-App
The webapp will allow a user to prepare a work schedule. The user can specify what work stations exists (with the number of people needed), and the employees with their skills, and time constraints. 

# Files
work-scheduler.pl      Main project code
example-input-#.pl     Input facts for testing
testing.pl             Provided testing helper predicates
example-output-#.txt  Provided outputs examples

# How to run
Consult one input file , the project file and lastly the testing file.
?- consult('example-input-1.pl').
?- consult('work-scheduler.pl').
?- consult('testing.pl').

Then run queries. Only consult one input file at a time.

# Notes
Prolog uses backtracking to search for possible solutions. Since there can be many possible valid schedules, some testing queries may take a long time if Prolog keeps trying alternate schedules.

To avoid this issue, the program uses a cut (!) after one full valid schedule is created. This makes plan/1 commit to the first valid schedule it finds instead of continuing to search for every possible schedule.

# Possible Further Improvements

A possible improvement for this project would be to make the scheduler more efficient when searching for a valid plan. Right now, the program depends heavily on Prolog backtracking, which works but can become slow when there are many employees, workstations, or restrictions.



