<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***

A <code>TestResult</code> collects the results of executing
a test case. It is an instance of the Collecting Parameter pattern.
The test framework distinguishes between <i>failures</i> and <i>errors</i>.
A failure is anticipated and checked for with assertions. Errors are
unanticipated problems like an <code>ArrayIndexOutOfBoundsException</code>.

Based JUnit code
http://cvs.sourceforge.net/viewcvs.py/junit/junit/junit/framework/TestResult.java?view=markup

--->
<cfcomponent hint="A TestResult collects the results of executing a test case.">
	<cfproperty name="fFailures" type="array">
	<cfproperty name="fErrors" type="array">
	<cfproperty name="fListeners" type="array">
	<cfproperty name="fRunTests" type="numeric">
	<cfproperty name="fStop" type="boolean">
	
	<cffunction name="init" returntype="TestResult" access="public" hint="Test result constructor">
		<cfset VARIABLES.fFailures = ArrayNew(1)>
		<cfset VARIABLES.fErrors = ArrayNew(1)>
		<cfset VARIABLES.fListeners = ArrayNew(1)>
		<cfset VARIABLES.fRunTests = 0>
		<cfset VARIABLES.fStop = false>
		<cfreturn THIS>
	</cffunction>
	
	<cffunction name="addError" returntype="void" access="public" hint="Adds an error to the list of errors. The passed in exception caused the error.">
		<cfargument name="test" required="Yes" type="TestCase" hint="">
		<cfargument name="t" required="Yes" type="any" hint="">
		
		<cfset var e = CreateObject("Component", "iterators.ArrayIterator").init( cloneListeners() )>

		<cfset ArrayAppend(VARIABLES.fErrors, CreateObject("Component", "TestFailure").init(ARGUMENTS.test, ARGUMENTS.t) ) >
				
		<cfloop condition="#e.hasNext()#">
		   <cfset e.next().addError(ARGUMENTS.test, ARGUMENTS.t)>
		</cfloop>
	</cffunction>
	
	<cffunction name="addFailure" returntype="void" access="public" hint="Adds a failure to the list of failures. The passed in exception caused the failure.">
		<cfargument name="test" required="Yes" type="TestCase" hint="">
		<cfargument name="t" required="Yes" type="any" hint="">
		
		<cfset var e = CreateObject("Component", "iterators.ArrayIterator").init( cloneListeners() )>

		<cfset ArrayAppend(VARIABLES.fFailures, CreateObject("Component", "TestFailure").init(ARGUMENTS.test, ARGUMENTS.t) ) >
		
		<cfloop condition="#e.hasNext()#">
		   <cfset e.next().addFailure(ARGUMENTS.test, ARGUMENTS.t)>
		</cfloop>
	</cffunction>
	
	<cffunction name="addListener" returntype="void" access="public" hint="Registers a TestListener">
		<cfargument name="listener" required="Yes" type="any" hint="">
		<cfset ArrayAppend(VARIABLES.fListeners, ARGUMENTS.listener) >
	</cffunction>
		
	<cffunction name="cloneListeners" returntype="array" access="public" hint="Returns a copy of the listeners">
		<cfreturn VARIABLES.fListeners>
	</cffunction>
	
	<cffunction name="endTest" returntype="void" access="public" hint="Informs the result that a test was completed">
		<cfargument name="test" required="Yes" type="any" hint="">
		
		<cfset var e = CreateObject("Component", "iterators.ArrayIterator").init( cloneListeners() )>

		<cfloop condition="#e.hasNext()#">
		   <cfset e.next().endTest( ARGUMENTS.test )>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="errorCount" returntype="numeric" access="public" hint="Gets the number of detected errors.">
		<cfreturn ArrayLen( VARIABLES.fErrors )>		
	</cffunction>
	
	<cffunction name="errors" returntype="any" access="public" hint="Returns an Enumeration for the errors">
		<cfreturn CreateObject("Component", "iterators.ArrayIterator").init( VARIABLES.fErrors )>	
	</cffunction>
	
	<cffunction name="failureCount" returntype="numeric" access="public" hint="Gets the number of detected failures">
		<cfreturn ArrayLen( VARIABLES.fFailures )>
	</cffunction>
	
	<cffunction name="failures" returntype="any" access="public" hint="Returns an Enumeration for the failures">
		<cfreturn CreateObject("Component", "iterators.ArrayIterator").init( VARIABLES.fFailures )>	
	</cffunction>
	
	<cffunction name="run" returntype="void" access="public" hint="Returns an Enumeration for the failures">
		<cfargument name="test" required="Yes" type="TestCase" hint="">
		
		<cfset startTest( ARGUMENTS.test )>

		<cfset runProtected(ARGUMENTS.test, "runBare")>

		<cfset endTest( ARGUMENTS.test )>
	</cffunction>
	
	<cffunction name="runCount" returntype="numeric" access="public" hint="Gets the number of run tests">
		<cfreturn VARIABLES.fRunTests>
	</cffunction>
	
	<cffunction name="runProtected" returntype="void" access="public" hint="Runs a TestCase">
		<cfargument name="test" required="Yes" type="Test" hint="">
		<cfargument name="p" required="Yes" type="any" hint="">
		
		<cftry>
			<cfinvoke component="#ARGUMENTS.test#" method="#ARGUMENTS.p#">
			</cfinvoke>
			
			<cfcatch type="AssertionFailedError">
				<cfset addFailure(ARGUMENTS.test, CFCATCH )>
			</cfcatch>
			<cfcatch type="java.lang.ThreadDeath">
				<cfthrow message="#CFCATCH.Message#" type="#CFCATCH.Type#" errorcode="#CFCATCH.ErrNumber#" detail="#CFCATCH.Detail#">
			</cfcatch>
			<cfcatch type="Any">
				<cfset addError(ARGUMENTS.test, CFCATCH )> 
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="shouldStop" returntype="boolean" access="public" hint="Checks whether the test run should stop">
		<cfreturn VARIABLES.fStop>	
	</cffunction>
	
	<cffunction name="startTest" returntype="void" access="public" hint="Informs the result that a test will be started.">
		<cfargument name="test" required="Yes" type="any" hint="">
		
		<cfset var count = test.countTestCases()>
		<cfset var e = CreateObject("Component", "iterators.ArrayIterator").init( cloneListeners() )>

		<cfset VARIABLES.fRunTests = VARIABLES.fRunTests+1>
		
		<cfloop condition="#e.hasNext()#">
		   <cfset e.next().startTest( ARGUMENTS.test )>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="stop" returntype="void" access="public" hint="Marks that the test run should stop">
		<cfset VARIABLES.fStop = true>	
	</cffunction>
	
	<cffunction name="wasSuccessful" returntype="boolean" access="public" hint="Returns whether the entire test was successful or not">
		<cfif failureCount() IS 0 AND errorCount() IS 0>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
</cfcomponent>
