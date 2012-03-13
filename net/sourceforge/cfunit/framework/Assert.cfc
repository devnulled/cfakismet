<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***

Based JUnit code
http://cvs.sourceforge.net/viewcvs.py/junit/junit/junit/framework/Assert.java?view=markup
--->
<cfcomponent hint="A set of assert methods.  Messages are only displayed when an assert fails.">
	
	<cffunction name="init" returntype="Assert" access="public">
		<cfreturn THIS>
	</cffunction>
	
	<cffunction name="assertTrue" returntype="void" access="public" hint="Asserts that a condition is true. If it isn't it throws an AssertionFailedError with the given message.">
		<cfargument name="message" required="no" default="" type="string">
		<cfargument name="condition" required="yes" type="boolean">
		
		<cfif NOT ARGUMENTS.condition>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="#ARGUMENTS.message#">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
	<cffunction name="assertFalse" returntype="void" access="public" hint="Asserts that a condition is false. If it isn't it throws an AssertionFailedError with the given message.">
		<cfargument name="message" required="no" default="" type="string">
		<cfargument name="condition" required="yes" type="boolean">
	
		<cfif ARGUMENTS.condition>
			<cfinvoke method="fail">
				<cfinvokeargument name="message" value="#ARGUMENTS.message#">
			</cfinvoke>
		</cfif>
		
	</cffunction>
	
	<cffunction name="assertEquals" returntype="void" access="public" hint="Asserts that two objects are equal. If they are not an AssertionFailedError is thrown with the given message.">
		<cfargument name="message" required="no" default="" type="string">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		
		<cfset var expectedMetaData = getMetaData(ARGUMENTS.expected) />
		<cfset var actualMetaData = getMetaData(ARGUMENTS.actual) />
		<cfset var queryDiffs = "" />
		
		<cfif isCFC(ARGUMENTS.expected)>
			<cfset ARGUMENTS.expected = ARGUMENTS.expected.toXML( true ) />
		</cfif>
		
		<cfif isCFC(ARGUMENTS.actual)>
			<cfset ARGUMENTS.actual = ARGUMENTS.actual.toXML( true ) />
		</cfif>
		
		<cfif isQuery( ARGUMENTS.expected )>
			<cfset queryDiffs = queryCompare(ARGUMENTS.expected, ARGUMENTS.actual)>
			
			<cfif NOT Len(Trim( queryDiffs ))>
				<cfreturn>
			</cfif>
			<cfset fail( ARGUMENTS.message & ": " & queryDiffs )>
		</cfif>
		
		<!--- Are the values numeric? --->
		<cfif isNumeric( ARGUMENTS.expected )>
			<cfif isNumeric( ARGUMENTS.actual )>
				<!--- Numbers compared using EQ to avoid the numbers' formatting form interfering  --->
				<cfif ARGUMENTS.expected EQ ARGUMENTS.actual>
					<cfreturn />
				</cfif>
			</cfif>
		</cfif>
		
		<cfif ARGUMENTS.expected.equals( ARGUMENTS.actual )>
			<cfreturn>
		</cfif>
				
		<cfinvoke method="failNotEquals">
			<cfinvokeargument name="message" value="#ARGUMENTS.message#">
			<cfinvokeargument name="expected" value="#ARGUMENTS.expected#">
			<cfinvokeargument name="actual" value="#ARGUMENTS.actual#">
		</cfinvoke>
		
	</cffunction>
	
	<cffunction name="assertSame" returntype="void" access="public" hint="Asserts that two objects refer to the same object. If they are not an AssertionFailedError is thrown with the given message.">
		<cfargument name="message" required="no" default="" type="string">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		
		<!--- CHECK: Are the objects the same? --->
		<cfif isSame( ARGUMENTS.expected, ARGUMENTS.actual )>
			<!--- Both objects the same, return without failure --->
			<cfreturn />
		
		<cfelse>
			<!--- Objects the not same, throw failure --->
			<cfinvoke method="failNotEquals">
				<cfinvokeargument name="message" value="#ARGUMENTS.message#">
				<cfinvokeargument name="expected" value="#ObjectToString(ARGUMENTS.expected)#">
				<cfinvokeargument name="actual" value="#ObjectToString(ARGUMENTS.actual)#">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<cffunction name="assertNotSame" returntype="void" access="public" hint="Asserts that two objects do not refer to the same object. If they do refer to the same object an AssertionFailedError is thrown with the given message.">
		<cfargument name="message" required="no" default="" type="string">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		
		<!--- CHECK: Are the objects not the same? --->
		<cfif NOT isSame( ARGUMENTS.expected, ARGUMENTS.actual )>
			<!--- Objects the not same, return without failure --->
			<cfreturn />
			
		<cfelse>
			<!--- Both objects the same, throw failure --->
			<cfinvoke method="failNotEquals">
				<cfinvokeargument name="message" value="#ARGUMENTS.message#">
				<cfinvokeargument name="expected" value="#ObjectToString(ARGUMENTS.expected)#">
				<cfinvokeargument name="actual" value="#ObjectToString(ARGUMENTS.actual)#">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	<cffunction name="isSame" returntype="boolean" access="public" hint="Checks to see if two objects refer to the same object.">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		
		<cfset var key = createuuid() />
		<cfset var temp = "" />
		
		<!--- CHECK: Is expected object an array? --->
		<cfif isArray(ARGUMENTS.expected)>
			<!--- CHECK: Is actual object also an array? --->
			<cfif isArray(ARGUMENTS.actual)>
				<!--- Append unique key to expected array --->
				<cfset ArrayAppend(ARGUMENTS.expected, key) />
				<!--- CHECK: Does actual array also have unique key appended? --->
				<cfif ArrayLen( ARGUMENTS.actual ) GT 0>
					<cfif ARGUMENTS.actual[ArrayLen(ARGUMENTS.actual)] EQ key>
						<!--- Both variables refer to same object, delete unique key and return without failure --->
						<cfset ArrayDeleteAt(ARGUMENTS.expected, ArrayLen(ARGUMENTS.expected)) />
						<!--- WARNING: This only works for CFMX 6.*, this no longer works in CFMX 7.* because --->
						<!--- CFMX 7 passes arrays by value into CFC arguments instead of by refrence. --->
						<cfreturn true />
					</cfif>
				</cfif>
				<!--- Variables do not refer to same object, delete unique key and return failure --->
				<cfset ArrayDeleteAt(ARGUMENTS.expected, ArrayLen(ARGUMENTS.expected)) />
			</cfif>	
			
		<!--- CHECK: Is expected object a structure? --->
		<cfelseif isStruct(ARGUMENTS.expected)>
			<!--- CHECK: Is actual object also a structure? --->
			<cfif isStruct(ARGUMENTS.actual)>
				<!--- Insert unique key into expected structure --->
				<cfset StructInsert(ARGUMENTS.expected, key, "CFUnit Test") />
				<!--- CHECK: Does actual structure also have unique key Inserted? --->
				<cfif StructKeyExists(ARGUMENTS.actual, key)>
					<!--- Both variables refer to same object, delete unique key and return without failure --->
					<cfset StructDelete(ARGUMENTS.expected, key) />
					<cfreturn true />
				</cfif>
				<!--- Variables do not refer to same object, delete unique key and return failure --->
				<cfset StructDelete(ARGUMENTS.expected, key) />
			</cfif>
			
		<!--- CHECK: Is expected object a query? --->
		<cfelseif isQuery(ARGUMENTS.expected)>
			<!--- CHECK: Is actual object also a query? --->
			<cfif isQuery(ARGUMENTS.actual)>
				<!--- CHECK: Compare both queries for equality? --->
				<cfif ARGUMENTS.expected.equals( ARGUMENTS.actual )>
					<!--- Both queries the same object, return without failure --->
					<cfreturn true />
				</cfif>
			</cfif>
			
		<!--- All other object types --->
		<cfelse>
			<!--- Format both objects into strings so that they can be compared --->
			<cfset ARGUMENTS.expected = ObjectToString(ARGUMENTS.expected) />
			<cfset ARGUMENTS.actual = ObjectToString(ARGUMENTS.actual) />
			
			<!--- CHECK: Compare both objects for equality? --->
			<cfif ARGUMENTS.expected.equals( ARGUMENTS.actual )>
				<!--- Both objects the same object, return without failure --->
				<cfreturn true />
			</cfif>
		</cfif>
		
		<!--- If we got this far, then the object are not equal, and we will throw a failure. --->
		<cfreturn false />
	</cffunction>
	
	<cffunction name="assertOutputs" returntype="void" access="public" hint="Asserts that a CFML Template (*.cfm file) or CFML Module outputs the expected results. Is if does not an AssertionFailedError is thrown with the given message.">
		<cfargument name="template" required="yes" type="string" hint="An absolute path to the template or module to execute">
		<cfargument name="expected" required="yes" type="string" hint="The expected output. This can either be a string or a file path. The file path can either be absolute or relative.">
		<cfargument name="message" required="no" default="" type="any" hint="The message which will be returned upon failure.">
		<cfargument name="type" required="no" default="TEMPLATE" type="string" hint="Either “MODULE” or “TEMPLATE”. Default is “TEMPLATE”.">
		<cfargument name="args" required="no" type="struct" hint="A structure of arguments for the template. If the template is a module, they will be passes in as attributes.">
		<cfargument name="ignore" required="no" type="array" hint="A collection of regular expressions for text to ignore in both the 'expected' and the 'actual' outputs.">
		
		<cfset var actual = "" />
		<cfset var i = 0 />
		
		<!--- CHECK: Is the expected string a file path --->
		<cfif FileExists(ExpandPath( ARGUMENTS.expected ))>
			<!--- Read the file, updating the 'expected' string ---> 
			<cffile action="read" file="#ExpandPath( ARGUMENTS.expected )#" variable="ARGUMENTS.expected" />
		</cfif>
		
		<!--- CHECK: Is this a module? --->
		<cfif ARGUMENTS.type IS "MODULE">
			<!--- Default the 'args' collection to an empty structure. --->
			<cfparam name="ARGUMENTS.args" default="#StructNew()#" />
			<!--- Get the output of the module --->
			<cfsavecontent variable="actual">
				<cfmodule template="#ARGUMENTS.template#" attributecollection="#ARGUMENTS.args#">
			</cfsavecontent>
		<cfelse>
			<!--- CHECK: Is the 'args' variable defined? --->
			<cfif IsDefined("ARGUMENTS.args")>
				<!--- CHECK: Is the 'args' variable a structure --->
				<cfif IsStruct(ARGUMENTS.args)>
					<!--- Iterate over the args, setting each one --->
					<cfloop collection="#ARGUMENTS.args#" item="thisVar">
						<cfset "#thisVar#" = ARGUMENTS.args[thisVar]>
					</cfloop>
				</cfif>
			</cfif>
			<!--- Get the output of the template --->
			<cfsavecontent variable="actual">
				<cfinclude template="#ARGUMENTS.template#">
			</cfsavecontent>
		</cfif>
		
		<!--- Strip out text we want to ignore --->
		<cfif IsDefined("ARGUMENTS.ignore")>
			<cfloop from="1" to="#ArrayLen(ARGUMENTS.ignore)#" index="i">
				<cfset actual = REReplace(actual, ARGUMENTS.ignore[i], "", "all") />
				<cfset ARGUMENTS.expected = REReplace(ARGUMENTS.expected, ARGUMENTS.ignore[i], "", "all") />
			</cfloop>
		</cfif>
		
		<!--- CHECK: Does the template/module output not contain the expected string? --->
		<cfif NOT (Trim(actual) CONTAINS Trim(ARGUMENTS.expected))>
			<!--- Throw failure --->
			<cfinvoke method="failNotEquals">
				<cfinvokeargument name="message" value="#ARGUMENTS.message#">
				<cfinvokeargument name="expected" value="#Trim(ARGUMENTS.expected)#">
				<cfinvokeargument name="actual" value="#Trim(actual)#">
			</cfinvoke>
		</cfif>
	</cffunction>
	
	
	<!--- Utilitarian methods --->
	<cffunction name="ObjectToString" returntype="string" access="public">
		<cfargument name="object" required="yes" type="any">
		
		<cfset var metaData = ""/>
		
		<!--- CHECK: Is object a complex value? --->
		<cfif isObject(ARGUMENTS.object)>
			<!--- CHECK: Is object a CFC? --->
			<cfset metaData = getMetaData(ARGUMENTS.object)>
			<cfif structKeyExists(metaData,"type") AND metaData.type is "component">
				<cfset ARGUMENTS.object = Replace(Replace(StructCopy( ARGUMENTS.object ).toString(), "{", ""), "}", "")/>
				<cfset ARGUMENTS.object = ListToArray( ARGUMENTS.object )/>
				<cfset ArraySort(ARGUMENTS.object, "text") />
			</cfif>
		</cfif>
		
		<cfreturn Trim(ARGUMENTS.object.toString()) />
	</cffunction>
	
	<cffunction name="generateOutputs" returntype="void" access="public" hint="Asserts that two objects are equal. If they are not an AssertionFailedError is thrown with the given message.">
		<cfargument name="template" required="yes" type="string">
		<cfargument name="file" required="yes" type="string">
		<cfargument name="type" required="no" default="TEMPLATE" type="string">
		<cfargument name="args" required="no" type="struct">
		
		<cfset var output = "" />
		
		<!--- CHECK: Is this a module? --->
		<cfif ARGUMENTS.type IS "MODULE">
			<!--- Default the 'args' collection to an empty structure. --->
			<cfparam name="ARGUMENTS.args" default="#StructNew()#" />
			<!--- Get the output of the module --->
			<cfsavecontent variable="output">
				<cfmodule template="#ARGUMENTS.template#" attributecollection="#ARGUMENTS.args#">
			</cfsavecontent>
		<cfelse>
			<!--- CHECK: Is the 'args' variable defined? --->
			<cfif IsDefined("ARGUMENTS.args")>
				<!--- CHECK: Is the 'args' variable a structure --->
				<cfif IsStruct(ARGUMENTS.args)>
					<!--- Iterate over the args, setting each one --->
					<cfloop collection="#ARGUMENTS.args#" item="thisVar">
						<cfset "#thisVar#" = ARGUMENTS.args[thisVar]>
					</cfloop>
				</cfif>
			</cfif>
			<!--- Get the output of the template --->
			<cfsavecontent variable="output">
				<cfinclude template="#ARGUMENTS.template#">
			</cfsavecontent>
		</cfif>
		
		<!--- Save the template/module's output to file --->
		<cffile action="write" file="#ExpandPath( ARGUMENTS.file )#" output="#output#"  >
		
		<!--- Throw a failure, this generator should not be left in the test --->
		<cfinvoke method="fail">
			<cfinvokeargument name="message" value="Output File Generated">
		</cfinvoke>
		
	</cffunction>
	
	<!--- Failure Methods --->
	<cffunction name="fail" returntype="void" access="public" hint="Fails a test with the given message.">
		<cfargument name="message" required="no" default="" type="string">
		<cfthrow type="AssertionFailedError" errorcode="AssertionFailedError" message="#ARGUMENTS.message#">
	</cffunction>
	
	<cffunction name="failNotEquals" returntype="void" access="public" hint="Fails a test with the given message.">
		<cfargument name="message" required="no" default="" type="string">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		
		<cfinvoke method="fail">
			<cfinvokeargument name="message" value="#format(ARGUMENTS.message, ARGUMENTS.expected, ARGUMENTS.actual)#">
		</cfinvoke>
		
	</cffunction>

	<cffunction name="format" returntype="string" access="public">
		<cfargument name="message" required="no" default="" type="string">
		<cfargument name="expected" required="yes" type="any">
		<cfargument name="actual" required="yes" type="any">
		
		<cfreturn ARGUMENTS.message & ": expected:<" & getStringDiff(ARGUMENTS.expected.toString(), ARGUMENTS.actual.toString()) & "> but was:<" & getStringDiff(ARGUMENTS.actual.toString(), ARGUMENTS.expected.toString()) & ">">>
	</cffunction>
	
	
	<cffunction name="queryCompare" access="private" returntype="string" output="false">
		<cfargument name="expected" type="query" required="true" />
		<cfargument name="actual" type="query" required="true" />
		
		<cfset var changedrows = ArrayNew( 1 )>
		<cfset var columns = ARGUMENTS.expected.columnlist>
		<cfset var col = "">
		<cfset var expectedColData = "">
		<cfset var actualColData = "">
		<cfset var i = 0>
				
		<cfif ARGUMENTS.expected.columnlist NEQ ARGUMENTS.actual.columnlist>
			<cfreturn "Columns Don't Match: expected:<#ARGUMENTS.expected.columnlist#> actual:<#ARGUMENTS.actual.columnlist#>">
		</cfif>
	
		<cfif ARGUMENTS.expected.recordcount NEQ ARGUMENTS.actual.recordcount>
			<cfreturn "Recordcounts Don't Match: expected:<#ARGUMENTS.expected.recordcount#> actual:<#ARGUMENTS.actual.recordcount#>">
		</cfif>
		
		<cfloop query="ARGUMENTS.expected">
			<cfset i = i + 1>
			<cfloop list="#columns#" index="col">
				<cfset expectedColData = expectedColData & "{" & ARGUMENTS.expected[col][i] & "}">
				<cfset actualColData = actualColData & "{" & ARGUMENTS.actual[col][i] & "}">
			</cfloop>
			
			<cfif expectedColData NEQ actualColData>
				<cfset ArrayAppend(changedrows, "row " & i & ": expected:<" & expectedColData & "> actual:<" & actualColData)>
				
			</cfif>
		</cfloop>

		<cfif ArrayLen( changedrows ) GT 0>
			<cfreturn "Rows Don't Match: " & changedrows.toString()>
		</cfif>
		
		<cfreturn "">
		
	</cffunction>
	
	<cffunction name="getStringDiff" access="private" returntype="string" output="false" hint="Function used to get the differences between two strings.">
		<cfargument name="a" required="Yes" type="string" hint="The string to get the differences of" />
		<cfargument name="b" required="Yes" type="string" hint="The string to compare against" />
	
		<!--- Initialize local variables --->
		<cfset var index = 0 />
		<cfset var final = ARGUMENTS.a />
		<cfset var comp = ARGUMENTS.b />
		
		<!--- CHECK: Is the string less then 256 characters in length? --->		
		<cfif Len( final ) LT 256>
			<!--- String too short to both formatting, return whole string --->
			<cfreturn final />
		</cfif>
		
		<!--- LOOP: Iterate over the characters in the string --->
		<cfloop condition="index LT Len(final)">
			<cfset index = index + 1 />
			
			<!--- CHECK: Is the character at this index in both string equal? --->
			<cfif Mid(final, index, 1) NEQ Mid(comp, index, 1)>
				<cfbreak/>
			</cfif>
			
		</cfloop>
		
		<!--- CHECK: Are there more then 6 characters that are equal? --->
		<cfif index GT 13>
			<!--- Strip off the leftmost characters --->
			<cfset final = "{#index#}..." & Right(final, (Len(final)-index)+12) />
		</cfif>
		
		<!--- Reverse the strings, reset the index, and trim off the right side of the string. --->
		<cfset final = Reverse(final) />
		<cfset comp = Reverse(comp) />
		<cfset index = 0 />
		
		<!--- LOOP: Iterate over the characters in the string --->
		<cfloop condition="index LT Len(final)">
			<cfset index = index + 1 />
			
			<!--- CHECK: Is the character at this index in both string equal? --->
			<cfif Mid(final, index, 1) NEQ Mid(comp, index, 1)>
				<cfbreak/>
			</cfif>
			
		</cfloop>
		
		<!--- CHECK: Are there more then 6 characters that are equal? --->
		<cfif index GT 13>
			<cfset final = "..." & Right(final, (Len(final)-index)+12) />
		</cfif>
		
		<!--- Reverse the strings back to it original direction, and return it. --->
		<cfreturn Reverse(final)/>
	</cffunction>

	<!--- ### BEGIN: CFC to XML Conversion ### --->
	<!--- The following methods are used to convert a CFC to XML, allowing us to compare them for equality. --->
	<cffunction name="toXML" access="private" returntype="xml" output="no" hint="Used to convert a CFC to XML introspectively">
		<cfargument name="isRoot" type="boolean" default="false" hint="Is this the root XML node?"/>
		
		<cfset var myXML = "<onj/>" />
		
		<cfset var myMataData = getMetaData( THIS ) />
		<cfset var myProperties = ArrayNew(1) />
		<cfset var myName = myMataData["NAME"] />
		<cfset var index = "" />
		<cfset var item = "" />
		<cfset var thisElement = "">
		
		<!--- Create REQUEST level structure to retain references to objects during serialization --->
		<cfif NOT IsDefined("REQUEST.Interface$CFUnitID")>
			<cfset REQUEST.Interface$CFUnitID = StructNew() />
		</cfif>
		
		<!--- Get the properties of this class --->
		<cfif StructKeyExists(myMataData, "PROPERTIES")>
			<cfloop from="1" to="#ArrayLen(myMataData['PROPERTIES'])#" index="index">
				<cfset ArrayAppend(myProperties, myMataData["PROPERTIES"][index]) />
			</cfloop>
		</cfif>
		
		<!--- Get the properties of all extended classes --->
		<cfloop condition="#StructKeyExists(myMataData, 'EXTENDS')#">
			<cfset myMataData = myMataData["EXTENDS"]>
			<cfif StructKeyExists(myMataData, "PROPERTIES")>
				<cfloop from="1" to="#ArrayLen(myMataData['PROPERTIES'])#" index="index">
					<cfset ArrayAppend(myProperties, myMataData["PROPERTIES"][index]) />
				</cfloop>
			</cfif>
		</cfloop>
		
		<!--- Begin writing XML packet --->
		<cfsavecontent variable="myXML">
			<cfif ARGUMENTS.isRoot><?xml version="1.0" standalone="yes"?></cfif>
			<cfoutput>
				<obj name="root" type="#myName#">
					<cfloop from="1" to="#ArrayLen(myProperties)#" index="index">
						<cfset thisElement = myProperties[index]>
						<cfif StructKeyExists(VARIABLES, thisElement["name"])>
							<cfinvoke method="createXMLNode" component="#this#" thisName="#thisElement['name']#" thisValue="#VARIABLES[thisElement['name']]#"/>
						</cfif>
					</cfloop>
				</obj>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Clear REQUEST level structure that retains references to objects during serialization to prevent errors if another object is serialized later in request that contain some of the same objects. --->	
		<cfset StructClear(REQUEST.Interface$CFUnitID) />
		
		<cfreturn Trim(myXML) />
	</cffunction>
	
	<cffunction name="createXMLNode" access="private" returntype="void" output="yes" hint="Used to convert a any object to XML">
		<cfargument name="thisName" type="string" required="true"/>
		<cfargument name="thisValue" type="any" required="true"/>
	
		<cfset var item = ""/>
			
		<cfif IsSimpleValue( thisValue )>
			<obj name="#thisName#" type="simple">#thisValue#</obj>								
		<cfelseif IsArray( thisValue )>
			<obj name="#thisName#" type="array" columns="1">
				<cfloop from="1" to="#ArrayLen( thisValue )#" index="item">
					<cfinvoke method="createXMLNode" component="#THIS#" thisName="#item#" thisValue="#thisValue[item]#"/>
				</cfloop>
			</obj>
		<cfelseif THIS.IsCFC( thisValue )>
			
			<!--- CHECK: Was the CFC already serialized? --->
			<cfif StructKeyExists(thisValue, "Interface$CFUnitID") AND StructKeyExists(REQUEST.Interface$CFUnitID, thisValue.Interface$CFUnitID)>
				<!--- Set up refrence to serialized version of CFC --->
				<obj name="#thisName#" type="component" />
			<cfelse>
				<!--- Add in functions required serializing CFC --->
				<cfset StructAppend(thisValue, REQUEST.Interface$CFUnit, false ) />
				<cfset StructInsert(thisValue, "Interface$CFUnitID", CreateUUID(), true ) />
				
				<!--- Add unique key to global request structure --->
				<cfset StructInsert(REQUEST.Interface$CFUnitID, thisValue.Interface$CFUnitID, thisValue, true ) />
				
				<!--- Serialize CFC --->
				<obj name="#thisName#" type="component">#thisValue.toXML()#</obj>
			</cfif>
		<cfelseif IsStruct( thisValue )>
			<obj name="#thisName#" type="struct">
				<cfloop collection="#thisValue#" item="item">
					<cfinvoke method="createXMLNode" component="#THIS#" thisName="#item#" thisValue="#thisValue[item]#"/>
				</cfloop>
			</obj>
		<cfelseif IsQuery( thisValue )>
			<obj name="#thisName#" type="query" columns="#thisValue.ColumnList#">
				<cfloop query="thisValue">
					<cfloop list="#thisValue.ColumnList#" index="item">
						<cfinvoke method="createXMLNode" component="#THIS#" thisName="#item#" thisValue="#thisValue[item][thisValue.currentrow]#"/>
					</cfloop>
				</cfloop>
			</obj>
		<cfelse>
			<obj name="#thisName#" type="object" />
		</cfif>
	</cffunction>
	
	<cffunction name="IsCFC" access="private" returntype="boolean" output="no" hint="Returns a boolean for whether a CF variable is a CFC instance. Based on the isCFC function by Nathan Dintenfass (nathan@changemedia.com)">
		<cfargument name="objectToCheck" type="any" required="true" hint="The object to check. (Required)" />
		
		<!--- get the meta data of the object we're inspecting --->
		<cfset var metaData = getMetaData(ARGUMENTS.objectToCheck) />
		
		<!--- if it's an object, let's try getting the meta Data --->
		<cfif isObject(ARGUMENTS.objectToCheck) >
			<!--- if it has a type, and that type is "component", then it's a component --->
			<cfif structKeyExists(metaData,"type") AND metaData.type IS "component">
				<!--- Append Interface$CFUnit to CFC to make it serializable --->
				<cfset StructAppend(ARGUMENTS.objectToCheck, REQUEST.Interface$CFUnit, false ) />
				<cfreturn true />
			</cfif>
		</cfif>
		
		<!--- if we've gotten here, it must not have been a contentObject --->		
		<cfreturn false />
		
	</cffunction>
	
	<!--- Interface$CFUnit is used to allow CFC objects to made serializable  --->
	<!--- by appending the methods in this structure to the CFC. --->
	<cfset REQUEST.Interface$CFUnit = StructNew()/>
	<cfset StructInsert(REQUEST.Interface$CFUnit, "toXML", toXML) />
	<cfset StructInsert(REQUEST.Interface$CFUnit, "createXMLNode", createXMLNode) />
	<cfset StructInsert(REQUEST.Interface$CFUnit, "isCFC", isCFC) />
	
	<!--- ### END: CFC to XML Conversion ### --->
	
</cfcomponent>