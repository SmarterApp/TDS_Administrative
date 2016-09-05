# Welcome to the Administrative Scripts project
The [SmarterApp](http://smarterapp.org) Administrative repository contains administrative scripts for the configuration, installation, maintenance of the SmarterApp system.

##
This project is licensed under the [AIR Open Source License v1.0](http://www.smarterapp.org/documents/American_Institutes_for_Research_Open_Source_Software_License.pdf).

## Loading and Configuration Scripts

### TSB
Test package assessments can be loaded into Test Spec Bank with the help of the helper scripts located in the /tsb directory. TSB, Progman, and other properties must be defined in the load_reg_package.pl.cfg file before the loader scripts are executed. 

load_reg_package.pl - The perl script is used to load a single assessment into Test Spec Bank
	* usage: $ perl load_reg_package.pl --path="/path/to/tsb/registration/file.xml" --exec 
	* note: not including the --exec flag will result in a dry run - TSB will not be loaded unless --exec is specified.

batch_tsb_loader.sh - Shell script that wraps load_reg_package.pl for batch uploads of multiple assessments. 
	* usage: $ ./batch_tsb_loader.sh /path/to/tsb/registration/*.xml

### TDS (MySQL)
Test package assessments can be loaded into the TDS MySQL database with the helper of the mysql loader script located in the /tds directory. MySQL database properties will need to be defined within the script prior to execution.
 
batch_mysql_loader.sh - Shell script that calls the "itembank.loader" stored procedure to load assessments into the TDS Itembank database
	* usage: $ ./batch_mysql_loader.sh /path/to/tds/administration/*.xml

## Getting Involved ##
We would be happy to receive feedback on its capabilities, problems, or future enhancements:

* For general questions or discussions, please use the [Forum](http://forum.opentestsystem.org/viewforum.php?f=16).
* Use the **Issues** link to file bugs or enhancement requests.
* Feel free to **Fork** this project and develop your changes!
