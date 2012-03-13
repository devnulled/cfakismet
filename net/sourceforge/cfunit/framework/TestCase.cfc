<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***

A test case defines the fixture to run multiple tests. To define a test case<br>
<ol>
	<li>implement a subclass of TestCase</li>
	<li>define instance variables that store the state of the fixture</li>
	<li>initialize the fixture state by overriding <code>setUp</code></li>
	<li>clean-up after a test by overriding <code>tearDown</code></li>
</ol>
Each test runs in its own fixture so there
can be no side effects among test runs.
Here is an example:
<pre>
	<cfcomponent displayname="MathTest" extends="TestCase">
		<cfproperty name="fValue1" type="numeric">
		<cfproperty name="fValue2" type="numeric">
		
		<cffunction name="setUp" returntype="void" access="public">
			<cfset var fValue1 = 2.0>
			<cfset var fValue2 = 3.0>
		</cffunction>
	</cfcomponent>
</pre>

For each test implement a method which interacts
with the fixture. Verify the expected results with assertions specified
by calling <code>assertTrue</code> with a boolean.
<pre>
	...
	<cffunction name="testAdd" returntype="void" access="public">
		<cfset var result = fValue1 + fValue2>
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="expected" value="#numberFormat(5.0)#">
			<cfinvokeargument name="actual" value="#numberFormat(result)#">
		</cfinvoke>
	</cffunction>
	...
</pre>
Once the methods are defined you can run them. The framework supports
both a static type safe and more dynamic way to run a test.
In the static way you override the runTest method and define the method to
be invoked.
<pre>
	...
	<cffunction name="runTest" returntype="void" access="public">
		<cfset testAdd()>
	</cffunction>
	...
</pre>
The dynamic way uses reflection to implement <code>runTest</code>. It dynamically finds
and invokes a method.
In this case the name of the test case has to correspond to the test method
to be run.
<pre>
	<cfset result = CreateObject("component", "net.sourceforge.cfunit.framework.TestCase").createResult()>
	<cfinvoke component="MathTest" method="init" returnvariable="test">
		<cfinvokeargument name="name" value="testAdd">
	</cfinvoke>
	<cfset test.run( result )>
</pre>
The tests to be run can be collected into a TestSuite. CFUnit provides
different <i>test runners</i> which can run a test suite and collect the results.
A test runner either expects a static method <code>suite</code> as the entry
point to get a test to run or it will extract the suite automatically.
<pre>
	<cffunction name="suite" returntype="Test" access="public">
		<cfset var suite = CreateObject("component", "TestSuite").init()>
		<cfset suite.addTest( CreateObject("component", "MathTest").init("testAdd") )>
		<cfset suite.addTest( CreateObject("component", "MathTest").init("testDivideByZero") )>
		<cfreturn suite> 
	</cffunction>
</pre>

Based JUnit code
http://cvs.sourceforge.net/viewcvs.py/junit/junit/junit/framework/TestCase.java?view=markup
--->
<cfcomponent extends="Test" hint="A test case defines the fixture to run multiple tests.">
	<cfproperty name="fName" type="string" hint="The name of the test case">
	
	<cffunction name="init" returntype="TestCase" access="public" hint="Constructs a test case with the given name.">
		<cfargument name="name" required="No" default="" type="string" hint="The name of the test case">
		<cfset setName( ARGUMENTS.name )>
		<cfreturn THIS>
	</cffunction>
		
	<cffunction name="countTestCases" returntype="numeric" access="public" hint="Counts the number of test cases executed by run(TestResult result).">
		<cfreturn 1>
	</cffunction>
	
	<cffunction name="createResult" returntype="TestResult" access="public" hint="Creates a default TestResult object">
		<cfreturn CreateObject("Component","TestResult").init()>
	</cffunction>
	
	<cffunction name="run" returntype="void" access="public" hint="Runs the test case and collects the results in TestResult.">
		<cfargument name="result" required="Yes" type="TestResult" hint="The name of the test case method">
		<cfset ARGUMENTS.result.run( this )>
	</cffunction>
	
	<cffunction name="runBare" returntype="void" access="public" hint="Runs the bare test sequence.">
		<cfset var exception = "">
		
		<cfset setUp()>
		
		<cftry>
			<cfset runTest()>
			<cfcatch type="Any">
				<cfset exception = CFCATCH>
			</cfcatch>
		</cftry>

		<cftry>
			<cfset tearDown()>
			<cfcatch type="Any">
				<cfif NOT Len(Trim( exception ))>
					<cfset exception = CFCATCH>
				</cfif>
			</cfcatch>
		</cftry>

		<cfif Len(Trim( exception ))>
			<cfthrow object="#exception#">
		</cfif>
	</cffunction>
	
	<cffunction name="runTest" returntype="void" access="public" hint="Override to run the test and assert its state.">
		
		<cfset var cd = GetMetadata( this ) />
		<cfset var cname = cd["name"] />		
		<cfset var methods = ArrayConcat(ArrayNew(1), cd["FUNCTIONS"]) />
		<cfset var runMethod = StructNew() />
		<cfset var e = "" />
		<cfset var next = "" />
				
		<cfloop condition="#StructKeyExists(cd, 'EXTENDS')#">
			<cfset cd = cd["EXTENDS"]>
			<cfif StructKeyExists(cd, "FUNCTIONS")>
				<cfset methods = ArrayConcat(methods, cd["FUNCTIONS"])>
			</cfif>
		</cfloop>

		<cfset e = CreateObject("Component", "iterators.ArrayIterator").init( methods )>
		<cfloop condition="#e.hasNext()#">
			<cfset next = e.next()>
		   	<cfif next["name"] IS getName()>
				<cfset runMethod = next>
				<cfbreak>
			</cfif>
		</cfloop>
			
		<cfif StructIsEmpty( runMethod )>
			<cfset fail( "Test "&getName()&"() was not found in " & cname )>
		</cfif>
	
		<cfif structKeyExists(runMethod, "ACCESS")>
			<cfif runMethod["ACCESS"] NEQ "public">
				<cfset fail( "Access to test "&getName()&"() was no public in " & cname )>
			</cfif>
		</cfif>
		
		<cfinvoke component="#this#" method="#runMethod['name']#"></cfinvoke>
		
	</cffunction>
	
	<cffunction name="setUp" returntype="void" access="package" hint="Sets up the fixture, for example, open a network connection. This method is called before a test is executed.">
	</cffunction>
	
	<cffunction name="tearDown" returntype="void" access="package" hint="Tears down the fixture, for example, close a network connection. This method is called after a test is executed.">
	</cffunction>
	
	 <cffunction name="getString" returntype="string" access="public" hint="Returns a string representation of the test case">
		<cfset var cd = GetMetadata( this ) >
		<cfreturn getName() & "(" & cd["name"] & ")">
	</cffunction>
	
	<cffunction name="getName" returntype="string" access="public" hint="Gets the name of a TestCase">
		<cfif IsDefined("VARIABLES.fName")>
			<cfreturn VARIABLES.fName />
		<cfelse>
			<cfreturn ""/>
		</cfif>		
	</cffunction>
	
	<cffunction name="setName" returntype="string" access="public" hint="Sets the name of a TestCase">
		<cfargument name="name" required="Yes" type="string" hint="The name of the test case">
		<cfset VARIABLES.fName = ARGUMENTS.name>
	</cffunction>
	
	<cffunction name="execute" access="remote" returntype="void" output="yes" hint="Executes this test">		
		<cfargument name="html" required="No" default="false" type="boolean" />
		<cfargument name="verbose" required="No" default="false" type="boolean" />
		
		<cfset var thisTest = this />
		
		<!--- Create a test suite for this test --->
		<cfif NOT StructKeyExists(THIS, "suite")>
			<cfset thisTest = CreateObject("component", "net.sourceforge.cfunit.framework.TestSuite").init( getMetaData(this).name ) />
		</cfif>
		
		<cfif ARGUMENTS.html>
			<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
			
			<html>
			<head>
				<title>CFUnit - #getMetaData(this).name#</title>
			</head>
			
			<body>
				<cfinvoke component="TestRunner" method="run">
					<cfinvokeargument name="test" value="#thisTest#">
					<cfinvokeargument name="name" value="">	
					<cfinvokeargument name="verbose" value="#ARGUMENTS.verbose#">
				</cfinvoke>
			</body>
			</html> 
		<cfelse>
			<cfset thisTest = Trim(CreateObject("component", "TestRunner").textrun( thisTest, "", ARGUMENTS.verbose )) />
			<cfsetting showdebugoutput="No" enablecfoutputonly="Yes" />
			<cfcontent type="text/plain" reset="yes" />
			<cfoutput>#thisTest#</cfoutput>
			<cfreturn />
		</cfif>
	</cffunction>	
</cfcomponent>