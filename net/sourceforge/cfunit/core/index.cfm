<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***
---> 

<cfsilent>
	<cfset webroot = ExpandPath("/") />
	<cfset absDir = ExpandPath(".") />
	<cfset cfcPath = listChangeDelims( replaceNoCase(absDir,webroot, ""), ".", "\")  />

	<cfdirectory action = "list" directory = "#absDir#" name = "qTests" filter="Test*.cfc" />	
</cfsilent>

<cfoutput>
	<h1>CFUnit Tests For: #cfcPath#</h1>
	<cfloop query="qTests">
	<ul>
		<li><a href="#qTests.name#?method=execute&html=1&verbose=1">#qTests.name#</a></li>
	</ul>
	</cfloop>
</cfoutput>



