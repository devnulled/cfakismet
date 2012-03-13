<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***

*** @verion 1.1                                                ***
***          Mark Mandel (http://www.compoundtheory.com)       ***
***          Added assertXBasic() methods                      ***

Extra TestCase functions
Most of these functions are designed to allow someone to convert a CFCUnit
test case to a CFUnit test case by simply changing the test's parent class
form CFCUnit's TestCase to "net.sourceforge.cfunit.framework.TestCaseEstra"

In the future other concept function may be staged here for trial use.
--->
<cfcomponent extends="net.sourceforge.cfunit.framework.TestCase" output="false">
	
	<cffunction name="assertTrue" returntype="void" access="public" output="false">
		<cfargument name="condition" type="boolean" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset SUPER.assertTrue(ARGUMENTS.failureMessage, ARGUMENTS.condition)/>
	</cffunction>
	
	<cffunction name="assertFalse" returntype="void" access="public" output="false">
		<cfargument name="condition" type="boolean" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset SUPER.assertFalse(ARGUMENTS.failureMessage, ARGUMENTS.condition)/>
	</cffunction>
	
	<cffunction name="assertSimpleValue" returntype="void" access="public" output="false">
		<cfargument name="value" type="any" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset SUPER.assertTrue(ARGUMENTS.failureMessage, isSimpleValue(ARGUMENTS.Value))/>
	</cffunction>
	
	<cffunction name="assertComplexValue" returntype="void" access="public" output="false">
		<cfargument name="value" type="any" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset SUPER.assertFalse(ARGUMENTS.failureMessage, isSimpleValue(ARGUMENTS.Value))/>
	</cffunction>
	
	<cffunction name="assertComponent" returntype="void" access="public" output="false">
		<cfargument name="value" type="any" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset SUPER.assertTrue(ARGUMENTS.failureMessage, isCFC(ARGUMENTS.Value))/>
	</cffunction>
	
	<cffunction name="assertObject" returntype="void" access="public" output="false">
		<cfargument name="value" type="any" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset SUPER.assertTrue(ARGUMENTS.failureMessage, isObject(ARGUMENTS.Value))/>
	</cffunction>
	
	<cffunction name="assertEqualsString" returntype="void" access="public" output="false">
		<cfargument name="expected" type="string" required="true"/>
		<cfargument name="actual" type="string" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertEquals(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>

	<cffunction name="assertEqualsNumber" returntype="void" access="public" output="false">		
		<cfargument name="expected" type="numeric" required="true"/>
		<cfargument name="actual" type="numeric" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertEquals(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>
	
	<cffunction name="assertEqualsBoolean" returntype="void" access="public" output="false">
		<cfargument name="expected" type="boolean" required="true"/>
		<cfargument name="actual" type="boolean" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertEquals(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>
	
	<cffunction name="assertEqualsStruct" returntype="void" access="public" output="false">
		<cfargument name="expected" type="struct" required="true"/>
		<cfargument name="actual" type="struct" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertEquals(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>
	
	<cffunction name="assertEqualsArray" returntype="void" access="public" output="false">
		<cfargument name="expected" type="array" required="true"/>
		<cfargument name="actual" type="array" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertEquals(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>
	
	<cffunction name="assertSameStruct" returntype="void" access="public" output="false">
		<cfargument name="expected" type="struct" required="true"/>
		<cfargument name="actual" type="struct" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertSame(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>
	
	<cffunction name="assertSameComponent" returntype="void" access="public" output="false">
		<cfargument name="expected" type="WEB-INF.cftags.component" required="true"/>
		<cfargument name="actual" type="WEB-INF.cftags.component" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertSame(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>
	
	<cffunction name="assertNotSameStruct" returntype="void" access="public" output="false">
		<cfargument name="expected" type="struct" required="true"/>
		<cfargument name="actual" type="struct" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertNotSame(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>
	
	<cffunction name="assertNotSameComponent" returntype="void" access="public" output="false">
		<cfargument name="expected" type="WEB-INF.cftags.component" required="true"/>
		<cfargument name="actual" type="WEB-INF.cftags.component" required="true"/>
		<cfargument name="failureMessage" type="string" required="false" default=""/>
		<cfset assertNotSame(ARGUMENTS.failureMessage, ARGUMENTS.expected, ARGUMENTS.actual)/>
	</cffunction>
	
	
	<!--- asserts with default messages --->
	<cffunction name="assertFalseBasic" hint="AssertFalse with a default message" access="public" returntype="void" output="false">
		<cfargument name="condition" required="yes" type="any">
		<cfscript>
			assertFalse("Condition is not false", arguments.condition);
		</cfscript>
	</cffunction>
	
	<cffunction name="assertTrueBasic" hint="AssertTrue with a default message" access="public" returntype="void" output="false">
		<cfargument name="condition" required="yes" type="any">
		<cfscript>
			assertTrue("Condition is not true", arguments.condition);
		</cfscript>
	</cffunction>
	
	<cffunction name="assertEqualsBasic" hint="AssertEquals with a default message" access="public" returntype="void" output="false">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		<cfscript>
			assertEquals("Expected and Actual not equal", arguments.expected, arguments.actual);
		</cfscript>
	</cffunction>

	<cffunction name="assertNotSameBasic" hint="AssertNotSame with a default message" access="public" returntype="void" output="false">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		<cfscript>
			assertNotSame("Expected and Actual are the same", arguments.expected, arguments.actual);
		</cfscript>
	</cffunction>
	
	<cffunction name="assertSameBasic" hint="AssertSame with a default message" access="public" returntype="void" output="false">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		<cfscript>
			assertSame("Expected and Actual not the same", arguments.expected, arguments.actual);
		</cfscript>		
	</cffunction>
	
</cfcomponent>