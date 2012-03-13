<cfcomponent name="TesTestCase_same" extends="net.sourceforge.cfunit.framework.TestCase">
	<!--- TEST SAMES --->	
	<cffunction name="testSameSimple" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var expected = "abc">
		<cfset var actual = "abc">
		<cfset var expectedBad = "xyz">
		
		<cfinvoke method="assertSame">
			<cfinvokeargument name="message" value="AssertSame failed when it should have passes">
			<cfinvokeargument name="expected" value="#expected#">
			<cfinvokeargument name="actual" value="#actual#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertSame">
				<cfinvokeargument name="expected" value="#expectedBad#">
				<cfinvokeargument name="actual" value="#actual#">
			</cfinvoke>
				
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertSame failed to assert a simple value">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
	<!--- assertSame() does not work for arrays in CF MX 7 beacuase in that version array are not passed by refrence
	<cffunction name="testSameArray" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var object = ArrayNew(1)>
		<cfset var objectBad = ArrayNew(1)>
		
		
		<cfinvoke method="assertSame">
			<cfinvokeargument name="message" value="AssertSame failed when it should have passes, using an empty array">
			<cfinvokeargument name="expected" value="#object#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
				
 		<cfset ArrayAppend(object, "abc")>
 		<cfset ArrayAppend(object, "xyz")>
		<cfset ArrayAppend(objectBad, "abc")>
 		<cfset ArrayAppend(objectBad, "xyz")>
		
		<cfinvoke method="assertSame">
			<cfinvokeargument name="message" value="AssertSame failed when it should have passes, using a populated array">
			<cfinvokeargument name="expected" value="#object#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertSame changed the object so that it is no longer equal to what it was">
			<cfinvokeargument name="expected" value="#objectBad#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertSame">
				<cfinvokeargument name="expected" value="#objectBad#">
				<cfinvokeargument name="actual" value="#object#">
			</cfinvoke>
			
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertSame failed to assert an array">
			</cfinvoke>
		</cfif>
	</cffunction>
	--->
	
	<cffunction name="testSameStruct" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var object = StructNew()>
		<cfset var objectBad = StructNew()>
		
		<cfinvoke method="assertSame">
			<cfinvokeargument name="message" value="AssertSame failed when it should have passes, using an empty structure">
			<cfinvokeargument name="expected" value="#object#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
		
 		<cfset StructInsert(object, "key1", "abc")>
 		<cfset StructInsert(object, "key2", "xyz")>
		<cfset StructInsert(objectBad, "key1", "abc")>
		<cfset StructInsert(objectBad, "key2", "xyz")>
		
		<cfinvoke method="assertSame">
			<cfinvokeargument name="message" value="AssertSame failed when it should have passes, using a populated structure">
			<cfinvokeargument name="expected" value="#object#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
		
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="message" value="AssertSame changed the object so that it is no longer equal to what it was">
			<cfinvokeargument name="expected" value="#objectBad#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
				
		<cftry>
			<cfinvoke method="assertSame">
				<cfinvokeargument name="expected" value="#objectBad#">
				<cfinvokeargument name="actual" value="#object#">
			</cfinvoke>
			
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertSame failed to assert a structure">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<cffunction name="testSameCFC" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var object = CreateObject("component", "net.sourceforge.cfunit.framework.TestCase")>
		<cfset var objectBad = CreateObject("component", "net.sourceforge.cfunit.framework.TestCase")>
		
		<cfinvoke method="assertSame">
			<cfinvokeargument name="message" value="AssertSame failed when it should have passes">
			<cfinvokeargument name="expected" value="#object#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
		
		<cftry>
			<cfinvoke method="assertSame">
				<cfinvokeargument name="expected" value="#objectBad#">
				<cfinvokeargument name="actual" value="#object#">
			</cfinvoke>
			
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertSame failed to assert a CFC">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
	<cffunction name="testSameJavaObject" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var object = CreateObject("java", "java.lang.Object").init()>
		<cfset var objectBad = CreateObject("java", "java.lang.String").init("String Object")>
		
		<cfinvoke method="assertSame">
			<cfinvokeargument name="message" value="AssertSame failed when it should have passes">
			<cfinvokeargument name="expected" value="#object#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
				
		<cftry>
			<cfinvoke method="assertSame">
				<cfinvokeargument name="expected" value="#objectBad#">
				<cfinvokeargument name="actual" value="#object#">
			</cfinvoke>
			
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertSame failed to assert a Java object">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<cffunction name="testSameQuery" returntype="void" access="public">
		<cfset var bFailureThrown = false />
		<cfset var object = QueryNew("c1, c2, c3")>
		<cfset var objectBad = QueryNew("c1, c2, c3")>
		
		<cfset QueryAddRow(object, 2)>
		<cfset QueryAddRow(objectBad, 2)>
		
		<cfset querysetcell(object,"c1","abc","1")>
		<cfset querysetcell(object,"c2","def","1")>
		<cfset querysetcell(object,"c3","ghi","1")>
		<cfset querysetcell(object,"c1","123","2")>
		<cfset querysetcell(object,"c2","456","2")>
		<cfset querysetcell(object,"c3","789","2")>
		
		<cfset querysetcell(objectBad,"c1","abc","1")>
		<cfset querysetcell(objectBad,"c2","def","1")>
		<cfset querysetcell(objectBad,"c3","ghi","1")>
		<cfset querysetcell(objectBad,"c1","123","2")>
		<cfset querysetcell(objectBad,"c2","456","2")>
		<cfset querysetcell(objectBad,"c3","XXX","2")>
		
		<cfinvoke method="assertSame">
			<cfinvokeargument name="message" value="AssertSame failed when it should have passes">
			<cfinvokeargument name="expected" value="#object#">
			<cfinvokeargument name="actual" value="#object#">
		</cfinvoke>
				
		<cftry>
			<cfinvoke method="assertSame">
				<cfinvokeargument name="expected" value="#objectBad#">
				<cfinvokeargument name="actual" value="#object#">
			</cfinvoke>
			
			<cfcatch type="AssertionFailedError">
				<cfset bFailureThrown = true />
			</cfcatch>
		</cftry>
		
		<cfif NOT bFailureThrown>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="AssertSame failed to assert a query">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
</cfcomponent>