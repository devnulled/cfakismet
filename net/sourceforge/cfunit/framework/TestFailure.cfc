<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***

A <code>TestFailure</code> collects a failed test together with the caught exception.
@see TestResult
--->
<cfcomponent hint="A <code>TestFailure</code> collects a failed test together with the caught exception.">
	<cfproperty name="fFailedTest" type="TestCase">
	<cfproperty name="fThrownException" type="struct">
	
	<cffunction name="init" returntype="TestFailure" access="public" hint="Constructs a TestFailure with the given test and exception.">
		<cfargument name="fFailedTest" type="TestCase" required="Yes">
		<cfargument name="fThrownException" type="any" required="Yes">

		<cfset VARIABLES.fFailedTest = ARGUMENTS.fFailedTest>
		<cfset VARIABLES.fThrownException = ARGUMENTS.fThrownException>
		
		<cfreturn THIS>
	</cffunction>
	
	<cffunction name="failedTest" returntype="TestCase" access="public" hint="Gets the failed test.">
		<cfreturn VARIABLES.fFailedTest>
	</cffunction>
	
	<cffunction name="thrownException" returntype="any" access="public" hint="Gets the thrown exception.">
		<cfreturn VARIABLES.fThrownException>
	</cffunction>
	
	<cffunction name="getString" returntype="string" access="public" hint="Returns a short description of the failure.">
		<cfreturn failedTest().getString() & ": " & VARIABLES.fThrownException.message>
	</cffunction>
	
	<!--- TODO: Need to implement this method
	public String trace() {
		StringWriter stringWriter= new StringWriter();
		PrintWriter writer= new PrintWriter(stringWriter);
		thrownException().printStackTrace(writer);
		StringBuffer buffer= stringWriter.getBuffer();
		return buffer.toString();
	} --->
	
	<cffunction name="exceptionMessage" returntype="string" access="public">
		<cfreturn VARIABLES.fThrownException.message>
	</cffunction>
	
	<!--- <cffunction name="isFailure" returntype="boolean" access="public">
		<cfreturn thrownException() instanceof AssertionFailedError>
	</cffunction> TODO: How should we handle this? --->

</cfcomponent>