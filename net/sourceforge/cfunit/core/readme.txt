********************************
***         CFUnit           ***
***       Core Folder        ***
********************************

The CFUnit "core" folder contains a skeleton of file that can be duplicated to 
start a new test package. This is simply for convenience.

To use these files, simply copy and paste its content to your own testing 
directory (TestMyCFC.cfc is just an example and can be deleted). Then simply 
begin adding your own CFUnit tests. The index.cfm/run.cfm should automatically 
detect any CFCs with names beginning with the word "test".

The index.cfm file will read the directory it is in for any CFC files that 
begin with "test" and list links to each. Each link in the list can be clicked 
to execute that test and view its results.

The run.cfm will read the directory it is in for any CFC files that begin with 
"test" and attempt to execute all of them at once.  

The build.xml file is simply a starting template for a CFUnit-Ant build file. 
This requires that you have Ant installed and have downloaded the CFUnit-Ant 
plug-in from the CFUnit site: 
http://sourceforge.net/project/showfiles.php?group_id=145385
