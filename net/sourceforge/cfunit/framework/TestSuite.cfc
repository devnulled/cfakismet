<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***

A <code>TestSuite</code> is a <code>Composite</code> of Tests.
It runs a collection of test cases. Here is an example using
the dynamic test definition.
	<pre>
		<cfset suite = CreateObject("component", "TestSuite").init()>
		<cfset suite.addTest(  CreateObject("component", "MathTest").init("testAdd") )>
		<cfset suite.addTest(  CreateObject("component", "MathTest").init("testDivideByZero") )>
	</pre>
Alternatively, a TestSuite can extract the tests to be run automatically.
To do so you pass the class of your TestCase class to the
TestSuite constructor.
	<pre>
		<cfset suite = CreateObject("component", "TestSuite").init("MathTest")>
	</pre>
This constructor creates a suite with all the methods
starting with "test" that take no arguments.
<p />
A final option is to do the same for a large array of test classes.
	<pre>
		<cfset testClasses = ArrayNew(1)>
		<cfset ArrayAppend(testClasses, "MathTest")>
		<cfset ArrayAppend(testClasses, "AnotherTest")>
		<cfset suite = CreateObject("component", "net.sourceforge.cfunit.framework.TestSuite").init( testClasses )>
	</pre>
	
Based JUnit code
http://cvs.sourceforge.net/viewcvs.py/junit/junit/junit/framework/TestSuite.java?view=markup

--->

<cfcomponent extends="Test">
 	<cfproperty name="fName" type="string" hint="The name of the test case">
	<cfproperty name="fTests" type="array" default="ArrayNew(1)">
	<cfset fTests = ArrayNew(1)>
	
	<cffunction name="init" returntype="TestSuite">
		<cfargument name="classes" required="No" default="" type="any" hint="Classes to test. Can be a single Test class, or an array of Test classes for multiple classes.">
		<cfargument name="name" required="No" default="" type="string">
		
		<cfset var e = "" />
		
		<cfif NOT IsArray(ARGUMENTS.classes)>
			<cfif NOT IsSimpleValue(ARGUMENTS.classes)>
				<cfthrow message="The argument CLASSES passed to function init() is not of type array or string." type="InvalidArgumentType" detail="If the component name is specified as a type of this argument, the reason for this error might be that a definition file for such component cannot be found or is not accessible.">
			</cfif>
		</cfif>
		
		<cfif IsArray(ARGUMENTS.classes)>
			<!--- Mulitple classes provided, loop through each and add their methods --->
			<cfset e = CreateObject("Component", "iterators.ArrayIterator").init( ARGUMENTS.classes )>
			<cfloop condition="#e.hasNext()#">
				<cfset addTestSuite( e.next() )>
			</cfloop>
		<cfelse>
			<!--- A single test given, parse it and add its methods --->
			<cfset addTestSuite(ARGUMENTS.classes)>
		</cfif>
		
		
		<cfif Len(Trim( ARGUMENTS.name ))>
			<cfset setName(ARGUMENTS.name)>
		</cfif>
		
		<cfreturn THIS>
	</cffunction>
 
	<cffunction name="setName" access="public" returntype="void" hint="Sets the name of the suite.">
		<cfargument name="name" required="Yes" type="string" hint="The name to set">
		<cfset VARIABLES.fName = ARGUMENTS.name> 
	</cffunction>
	
	<cffunction name="getName" access="public" returntype="string" hint="Returns the name of the suite. Not all  test suites have a name and this method can return blank.">
		<cfif IsDefined("VARIABLES.fName")>
			<cfreturn VARIABLES.fName>
		<cfelse>
			<cfreturn "">
		</cfif> 
	</cffunction>
	 
	<cffunction name="addTest" access="public" returntype="void" hint="Adds a test to the suite">
		<cfargument name="test" required="Yes" type="Test">
		<cfset ArrayAppend( getTests(), ARGUMENTS.test )>
	</cffunction>
	
	<cffunction name="addTestSuite" access="public" returntype="void" hint="Adds the tests from the given class to the suite">
		<cfargument name="classname" required="Yes" type="string">
		
		<!--- Initialize local variables --->
		<cfset var methods = ArrayNew(1)>	
		<cfset var classTemplate = "">
		<cfset var cd = "">
		<cfset var i = 0>
		<cfset var len = 0>
		<cfset var names = "">
		
		<cfif Len(Trim( ARGUMENTS.classname ))>
			
			<!--- Get the root CFC and its metadata --->
			<cfset classTemplate = createObject("component", ARGUMENTS.classname)>
			<cfset cd = GetMetadata( classTemplate )>
			<cfset setName( cd["NAME"] )>
			
			<!--- CHECK: Are there any functions in this CFC --->
			<cfif StructKeyExists(cd,  "FUNCTIONS")>
				
				<!--- Set the methods array to the root CFC's methods. --->
				<!--- <cfset methods = cd["FUNCTIONS"]>	 --->	
				<cfset methods = ArrayConcat(methods, cd["FUNCTIONS"])>
				
				<!--- Iterate over any extended CFCs to get their methods too --->
				<cfloop condition="#StructKeyExists(cd, 'EXTENDS')#">
					<!--- Reset our current metadata to the extended CFC's metadata --->
					<cfset cd = cd["EXTENDS"]>
					
					<!--- CHECK: Are there any functions in this CFC --->
					<cfif StructKeyExists(cd, "FUNCTIONS")>
						<!--- Append this CFC's methods to the existing array of methods --->
						<cfset methods = ArrayConcat(methods, cd["FUNCTIONS"])>
					</cfif>
				</cfloop>
				
			</cfif>
			
			<!--- Iterate over all methods found, and attempt to add them as a test --->
			<cfset len = ArrayLen( methods )>
			<cfloop from="1" to="#len#" index="i">
				<cfset addTestMethod( methods[i], names, ARGUMENTS.classname)>
			</cfloop>
			
			<!--- TODO: Give wanring if no methods found (<cfif ArrayLen( getTests() )></cfif>) --->
		</cfif>
		
	</cffunction>
		
	<cffunction name="addTestMethod" access="public" returntype="void" hint="Adds the tests from the given class to the suite">
		<cfargument name="method" required="Yes" type="Any">
		<cfargument name="names" required="Yes" type="string">
		<cfargument name="testClass" required="Yes" type="string">
		
		<cfset var name = ARGUMENTS.method["name"]>
		
		<cfif ListFindNoCase(ARGUMENTS.names, name)>
			<cfreturn>
		</cfif>
		
		<cfif NOT isPublicTestMethod( ARGUMENTS.method )>
			<cfif NOT isTestMethod( ARGUMENTS.method )>
				<!--- TODO: Add warning to outgoing messages --->
				<cfreturn>
			</cfif>
		</cfif>
		
		<cfset ARGUMENTS.names = ListAppend(ARGUMENTS.names, name)>
		<cfset addTest( createTest( ARGUMENTS.testClass, name ) )> 
	</cffunction>
	 
	<cffunction name="isPublicTestMethod" access="private" returntype="boolean">
		<cfargument name="method" required="Yes" type="Any">
		
		<cfif isTestMethod( ARGUMENTS.method )>
			<cfif structKeyExists(ARGUMENTS.method, "access")>
				<cfif ARGUMENTS.method["access"] IS "public">
					<cfreturn true>
				<cfelse>
					<cfreturn false>
				</cfif>
			<cfelse>
				<cfreturn true>
			</cfif>
		<cfelse>
			<cfreturn false>
		</cfif>
		
	</cffunction>
	
	<cffunction name="isTestMethod" access="private" returntype="boolean">
		<cfargument name="method" required="Yes" type="Any">
		<!--- TODO: Verify that method requires no arguments --->
		<cfif Left(ARGUMENTS.method["name"], 4) IS "test">
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="createTest" access="public" returntype="Test">
		<cfargument name="class" required="Yes" type="string">
		<cfargument name="name" required="Yes" type="string">
		
		<cfset var test = "">
		
		<!--- TODO: Verify init() method exists --->
		
		<cfinvoke component="#class#" method="init" returnvariable="test">
			<cfinvokeargument name="name" value="#ARGUMENTS.name#">
		</cfinvoke>
		
		<cfreturn test>
	</cffunction>

	<cffunction name="run" access="public" returntype="void" hint="Runs the tests and collects their result in a TestResult.">
		<cfargument name="result" required="Yes" type="TestResult">
		
		<cfset var tests = tests() />
		<cfset var test = "" />
		
		<cfloop condition="#tests.hasNext()#">
			<cfif ARGUMENTS.result.shouldStop()>
				<cfbreak>
			</cfif>
			<cfset test = tests.next()>
			<cfset runTest(test, ARGUMENTS.result)>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="runTest" returntype="void" access="public">
		<cfargument name="test" required="Yes" type="Test">
		<cfargument name="result" required="Yes" type="TestResult">
		<cfset ARGUMENTS.test.run( ARGUMENTS.result )>
	</cffunction>
	
		
	<cffunction name="getTests" returntype="array" access="public">
		<cfreturn VARIABLES.fTests>	
	</cffunction>
	
	<cffunction name="tests" returntype="any" access="public" hint="Returns the tests as an enumeration">
		<cfreturn CreateObject("Component", "iterators.ArrayIterator").init( getTests() )>	
	</cffunction>
		
	<cffunction name="countTestCases" access="public" returntype="numeric" hint="Counts the number of test cases that will be run by this test.">
		<cfset var count = 0 />
		<cfset var tests = tests() />
		<cfset var test = "" />
		
		<cfloop condition="#tests.hasNext()#">
			<cfset test = tests.next()>
			<cfset count = count + test.countTestCases()>
		</cfloop>
		
		<cfreturn count>
	</cffunction>
	
	<cffunction name="testAt" returntype="Test" access="public" hint="Returns the test at the given index">
		<cfargument name="index" required="Yes" type="numeric">
		<cfset var tests = getTests()>
		<cfreturn tests[ARGUMENTS.index]>
	</cffunction>
	
	<cffunction name="testCount" access="public" returntype="numeric" hint="Returns the number of tests in this suite">
		<cfreturn ArrayLen( getTests() )>
	</cffunction>
	
	<cffunction name="getString" access="public" returntype="string">
		<cfif getName() NEQ "">
			<cfreturn getName()>
		</cfif>
		<cfreturn SUPER.getName()>
	</cffunction>
</cfcomponent>