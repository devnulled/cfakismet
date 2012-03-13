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

	<cfset tests = ArrayNew(1)>
	
	<cfdirectory action = "list" directory = "#absDir#" name = "qTests" filter="Test*.cfc" />
	
	<cfloop query="qTests">
		<cfset arrayAppend(tests, cfcPath & "." & listFirst(qTests.name, ".") ) />
	</cfloop>
	
	<cfset testsuite = CreateObject("component", "net.sourceforge.cfunit.framework.TestSuite").init( tests )>

</cfsilent>

<cfinvoke component="net.sourceforge.cfunit.framework.TestRunner" method="run">
	<cfinvokeargument name="test" value="#testsuite#">
	<cfinvokeargument name="name" value="">	
</cfinvoke>

<cfoutput query="qTests">
<ul>
	<li><a href="#qTests.name#?method=execute&html=1&verbose=1">#qTests.name#</a></li>
</ul>
</cfoutput>



