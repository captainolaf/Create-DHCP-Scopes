README
------------------------------

INTRO
------------------------------

Create DHCP Scope script will do just that: configure DHCP scopes on target Windows server.
The script will prompt for file or path to file if (1) none is provided or (2) the
file provided is not found. The script will also prompt for server if (1) none is 
provided or (2) the server provided is not found.

After checking server and file scopes will be created based upon contents of CSV file
provided. It is recommended to use the provided Scope Template file for creation of
Scope file.

Use the scope template to enter values for creating each scope.

USAGE
------------------------------

Input options are:

-file path/to/file
-server $ServerName

If no input options are provided then user will be prompted to provide them