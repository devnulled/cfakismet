<!--- 
Tests the TestCase class
--->
 
<cfcomponent name="TestTestCase" extends="net.sourceforge.cfunit.framework.TestCase">

	<cfproperty name="fValue1" type="numeric">
	<cfproperty name="fValue2" type="numeric">
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfset fValue1 = 2.0>
		<cfset fValue2 = 3.0>
	</cffunction>
		
	<cffunction name="testAssertTrue" returntype="void" access="public">
		
		<cfset var bFailureThrown = false />
		
		<cfinvoke method="assertTrue">
			<cfinvokeargument name="message" value="AssertTrue failed when it should have passes">
			<cfinvokeargument name="condition" value="#YesNoFormat( true )#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertTrue">
				<cfinvokeargument name="message" value="This failure should be caught and not displayed">
				<cfinvokeargument name="condition" value="#YesNoFormat( false )#">
			</cfinvoke>
			
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertTrue failed to assert">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	
	<cffunction name="testAssertFalse" returntype="void" access="public">
		
		<cfset var bFailureThrown = false />
		
		<cfinvoke method="AssertFalse">
			<cfinvokeargument name="message" value="AssertFalse failed when it should have passes">
			<cfinvokeargument name="condition" value="#YesNoFormat( false )#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="AssertFalse">
				<cfinvokeargument name="message" value="This failure should be caught and not displayed">
				<cfinvokeargument name="condition" value="#YesNoFormat( true )#">
			</cfinvoke>
			
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertFalse failed to assert">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
	
	<!--- TEST EQUALS --->
	<cffunction name="testEqualsSimple" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var expected = "abc">
		<cfset var actual = "abc">
		<cfset var expectedBad = "xyz">
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertEquals failed when it should have passes">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertEquals">
				<cfinvokeargument name="message" value="This failure should be caught and not displayed">
				<cfinvokeargument name="expected" value="#expectedBad#">
				<cfinvokeargument name="actual" value="#actual#">
			</cfinvoke>
		
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertEquals failed to assert a simple value">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
	<cffunction name="testEqualsArray" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var expected = ArrayNew(1)>
		<cfset var actual = ArrayNew(1)>
		<cfset var expectedBad = ArrayNew(1)>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertEquals failed when it should have passes, using an empty array">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
 		<cfset ArrayAppend(expected, "abc")>
 		<cfset ArrayAppend(expected, "xyz")>
		<cfset ArrayAppend(actual, "abc")>
		<cfset ArrayAppend(actual, "xyz")>
		 <cfset ArrayAppend(expectedBad, "rst")>
 		<cfset ArrayAppend(expectedBad, "mno")>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertEquals failed when it should have passes, using a populated array">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertEquals">
				<cfinvokeargument name="message" value="This failure should be caught and not displayed">
				<cfinvokeargument name="expected" value="#expectedBad#">
				<cfinvokeargument name="actual" value="#actual#">
			</cfinvoke>
		
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertEquals failed to assert an array">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<cffunction name="testEqualsStruct" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var expected = StructNew()>
		<cfset var actual = StructNew()>
		<cfset var expectedBad = StructNew()>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertEquals failed when it should have passes, using an empty structure">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
 		<cfset StructInsert(expected, "key1", "abc")>
 		<cfset StructInsert(expected, "key2", "xyz")>
		<cfset StructInsert(actual, "key1", "abc")>
		<cfset StructInsert(actual, "key2", "xyz")>
		<cfset StructInsert(expectedBad, "key1", "rst")>
		<cfset StructInsert(expectedBad, "key2", "mno")>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertEquals failed when it should have passes, using a populated structure">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertEquals">
				<cfinvokeargument name="message" value="This failure should be caught and not displayed">
				<cfinvokeargument name="expected" value="#expectedBad#">
				<cfinvokeargument name="actual" value="#actual#">
			</cfinvoke>
		
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertEquals failed to assert a structure">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<cffunction name="testEqualsCFC" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var expected = CreateObject("component", "net.sourceforge.cfunit.framework.TestCase")>
		<cfset var actual = CreateObject("component", "net.sourceforge.cfunit.framework.TestCase")>
		<cfset var expectedBad = CreateObject("component", "net.sourceforge.cfunit.framework.TestCase")>
		
		<cfset expected.setName("GOOD NAME")/>
		<cfset actual.setName("GOOD NAME")/>
		<cfset expectedBad.setName("BAD NAME")/>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertEquals failed when it should have passes">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertEquals">
				<cfinvokeargument name="message" value="This failure should be caught and not displayed">
				<cfinvokeargument name="expected" value="#expectedBad#">
				<cfinvokeargument name="actual" value="#actual#">
			</cfinvoke>
		
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertEquals failed to assert a CFC">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
	<cffunction name="testEqualsJavaObject" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var expected = CreateObject("java", "java.lang.String").init("java.lang.String Object")>
		<cfset var actual = CreateObject("java", "java.lang.String").init("java.lang.String Object")>
		<cfset var expectedBad = CreateObject("java", "java.lang.Object").init()>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertEquals failed when it should have passes">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertEquals">
				<cfinvokeargument name="message" value="This failure should be caught and not displayed">
				<cfinvokeargument name="expected" value="#expectedBad#">
				<cfinvokeargument name="actual" value="#actual#">
			</cfinvoke>
		
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertEquals failed to assert a Java object">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<cffunction name="testEqualsQuery" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var expected = QueryNew("c1, c2, c3")>
		<cfset var actual = QueryNew("c1, c2, c3")>
		<cfset var expectedBad = QueryNew("c1, c2, c3")>
		
		<cfset QueryAddRow(expected, 2)>
		<cfset QueryAddRow(actual, 2)>
		<cfset QueryAddRow(expectedBad, 2)>
		
		<cfset querysetcell(expected,"c1","abc","1")>
		<cfset querysetcell(expected,"c2","def","1")>
		<cfset querysetcell(expected,"c3","ghi","1")>
		<cfset querysetcell(expected,"c1","123","2")>
		<cfset querysetcell(expected,"c2","456","2")>
		<cfset querysetcell(expected,"c3","789","2")>
		
		<cfset querysetcell(actual,"c1","abc","1")>
		<cfset querysetcell(actual,"c2","def","1")>
		<cfset querysetcell(actual,"c3","ghi","1")>
		<cfset querysetcell(actual,"c1","123","2")>
		<cfset querysetcell(actual,"c2","456","2")>
		<cfset querysetcell(actual,"c3","789","2")>
		
		<cfset querysetcell(expectedBad,"c1","abc","1")>
		<cfset querysetcell(expectedBad,"c2","def","1")>
		<cfset querysetcell(expectedBad,"c3","ghi","1")>
		<cfset querysetcell(expectedBad,"c1","123","2")>
		<cfset querysetcell(expectedBad,"c2","456","2")>
		<cfset querysetcell(expectedBad,"c3","XXX","2")>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertEquals failed when it should have passes">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertEquals">
				<cfinvokeargument name="message" value="This failure should be caught and not displayed">
				<cfinvokeargument name="expected" value="#expectedBad#">
				<cfinvokeargument name="actual" value="#actual#">
			</cfinvoke>
		
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertEquals failed to assert a query">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
	<cffunction name="testMissingAttributes4Test" hint="This method tests to verify that any test method in a test case CFC that does not have all its attributes, like 'access' or 'returntype', does not cause an error.">
		<!--- This method tests to verify that any test method in a test case CFC that does not have all its attributes, like "access" or "returntype", does not cause an error. --->
		<cfset var x = 1 />
	</cffunction>
	
	<cffunction name="testVarScope" hint="This tests to verify that all local CFC variables in the framework are var scoped.">
		<!--- This tests to verify that all local CFC variables in the framework are var scoped. --->
		<cfset var varScopeChecker = CreateObject("component", "VarScopeChecker").init() />
		<cfset var aErrors = varScopeChecker.check( expandPath("../framework") ) />
		
		<!--- Assert that there are no local variables that are not var scoped --->
		<cfset assertFalse("#arrayLen( aErrors )# local variable(s) were not var scoped. DETAILS: #aErrors.toString()#", arrayLen( aErrors ) ) />

	</cffunction>
	
</cfcomponent>