********************************
***         CFUnit           ***
***     User Document        ***
***          v4.0            ***
********************************

THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS COMMON PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR DISTRIBUTION OF THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE OF THIS AGREEMENT.

http://cfunit.sourceforge.net

This document has three sections:
1) Installation – A brief explanation of how to install the framework on your server
2) Installation Scenarios – More detailed examples of ways you can install CFUnit on your server
3) Setting Started – References to examples of how to use the CFUnit framework. 

If you find a bug within the framework, please feel free to report it in our sourceforge site: http://sourceforge.net/tracker/?group_id=145385&atid=761724

If you need help, please feel free to post a support request:
http://sourceforge.net/tracker/?group_id=145385&atid=761725
Or post your question in our online forum http://sourceforge.net/forum/?group_id=145385:

-----------------------------------------------------------
Installation
-----------------------------------------------------------
1 – Download the latest version of CFUnit framework at http://cfunit.sourceforge.net
2 – Unzip the contents of the file to where you wish the framework to exist on your ColdFusion server. This location must be accessible by the ColdFusion server, either on the server root or within a ColdFusion mapping. Where you place the CFUnit framework will influence how you reference the components. If you are new to CFUnit, you can place the framework on the server root. 

-----------------------------------------------------------
Installation Scenarios
-----------------------------------------------------------
The first decision that must be made when first using CFUnit is were to place the framework itself. Where you place the framework will determine how you refer to the frameworks CFCs when extending them or referring to them. Here we will illustrate a few different ways you can install the framework, and how you would refer to the framework’s CFCs in each scenario.

[SCENARIO 1]
The quickest and easiest way to implement CFUnit framework is to simply unzip it to the root of your CFML server. This will place a directory named “net” on your server root, which will contain the framework.
When extending or referring to any of the CFUnit CFCs, use this path:
   “net.sourceforge.cfunit.framework.*”
This is how the example below is written, so you would be able to follow that example without modification to its code.

[SCENARIO 2]
You can place the framework within a ColdFusion mapped location.
(Note: An example of why you might need to do this is discussed in part 8 of Benoit Hediard’s article on MVC for ColdFusion.
http://www.benorama.com/coldfusion/patterns/part8.htm)
To do this, follow these steps:
1 – Map a location within ColdFusion administrator:
   a – Login to you CF admin interface
   b – Click ‘Mappings’
   c – In the ‘directory path’ field enter ‘C:\CFusionMX\CF-INF\cfcomponents\net’, or any other location on the local machine which is outside your web server’s root.
   d – In the ‘logical path’ field enter ‘net’
   e – Click ‘Add Mapping’
2 – Unzip the framework to the directory you specified above. If you entered “C:\CFusionMX\CF-INF\cfcomponents\net”, unzip it to “C:\CFusionMX\CF-INF\cfcomponents\” because the root of the framework is ‘net’. Therefore after you have unzipped the framework you should see the ‘net’ folder within the ‘cfcomponents’ folder. (Note: if you already have a ‘net’ mapping, you do not need to create it, you can use that same mapping for CFUnit)
3 – Create the tests for the elements you wish to test, or use the example below. When extending or referring to any of the CFUnit CFCs, use this path:
   “net.sourceforge.cfunit.framework.*”
The examples below should work without modification.

[SCENARIO 3]
If you do not wish to place the framework on your web root, and are not able to create a mapping, then you can still place it in a subdirectory off you web root.
For example, if you would like to place the framework in the “somedirecotry” folder off the root of your site, your would simple unzip the framework to that location. The only difference between this and example one is that you will need to refer to the CFUnit CFCs differently:
   “somedirecotry.net.sourceforge.cfunit.framework.*”

-----------------------------------------------------------
Getting Started
-----------------------------------------------------------
For a primer on CFUnit, visit: http://cfunit.sourceforge.net/help-primer.php
For other help documents, visit: http://cfunit.sourceforge.net/docs.php 

For a very basic example of using CFUnit see the "CFUnitExample" folder.

There is also an optional set of core files that can be copy and pasted from the "core" folder. See the readme file in that folder for more information

