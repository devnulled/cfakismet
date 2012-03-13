<cfsilent>
	<cfsetting showdebugoutput="No">
	<cfset testClasses = ArrayNew(1)>
	<cfset ArrayAppend(testClasses, "net.sourceforge.cfunit.CFUnitExample.MyCFCTest")>
	<!--- Add as many test classes as you would like to the array --->
	<cfset suite = CreateObject("component", "net.sourceforge.cfunit.framework.TestSuite").init( testClasses )>
</cfsilent>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Unit Test Example</title>
</head>

<body
<h1>CFUnit Test</h1>
<cfinvoke component="net.sourceforge.cfunit.framework.TestRunner" method="run">
	<cfinvokeargument name="test" value="#suite#">
	<cfinvokeargument name="name" value="">
</cfinvoke>

 
</body>
</html>
</cfoutput>
