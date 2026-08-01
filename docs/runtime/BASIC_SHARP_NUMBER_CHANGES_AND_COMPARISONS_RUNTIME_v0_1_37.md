# BASIC# Number Changes and Comparisons Runtime v0.1.37

Before executing an increase or decrease, the runtime resolves the complete target selection and validates, in definition order:

1. every target exists;
2. every target has the named value;
3. every value is a whole number;
4. every computed result remains within 0 through 2,147,483,647.

Only after every check passes does mutation begin. This makes single-Thing and `every #kind` actions atomic.

After a successful action body, reactive IF settlement uses exact integer comparisons. Rules wake only on false-to-true transitions, remain active while true, rearm after becoming false, preserve source order, and retain the established loop limit.
