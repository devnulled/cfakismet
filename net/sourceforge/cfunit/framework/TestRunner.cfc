<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***

*** @verion 1.1                                                ***
***          Mark Mandel (http://www.compoundtheory.com)       ***
***          New design / clean up markup                      ***

*** @verion 1.2                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Bug fixes / clean up                              ***

Runs and outputs results of a Test, TestCase or TestSuite
--->
<cfcomponent>
	<cffunction name="qrun" access="public" output="No" returntype="string">
		<cfargument name="test" required="Yes" type="Test">
		<cfargument name="name" required="Yes" type="string">
		<cfargument name="verbose" required="No" default="true" type="boolean">
		
		<cfset var results = ""/>
		
		<cfinvoke component="TestCase" method="createResult" returnvariable="results">
		</cfinvoke>
		
		<cfif IsDefined("ARGUMENTS.test.suite")>
			<cfset ARGUMENTS.test.suite().run( results ) />
		<cfelse>
			<cfset ARGUMENTS.test.run( results ) />
		</cfif>
		
		<cfif results.errorCount() GT 0>
			<cfreturn "Error"/>
		<cfelseif results.failureCount() GT 0>
			<cfreturn "Failure"/>
		<cfelse>
			<cfreturn "Success"/>
		</cfif>

	</cffunction>
	
	<cffunction name="run" access="public" output="Yes" returntype="void">
		<cfargument name="test" required="Yes" type="Test">
		<cfargument name="name" required="Yes" type="string">
		<cfargument name="verbose" required="No" default="true" type="boolean">
		<cfargument name="styled" required="No" default="true" type="boolean">
		
		<cfset var startTime = 0 />
		<cfset var endTime = 0 />
		<cfset var execTime = 0 />
		<cfset var count = 0 />
		<cfset var styleType = "unknown" />
		<cfset var msg = "TBD" />
		<cfset var it = 0 />
		<cfset var thisMessage = "" />
		
			
		<cfsilent>
			<cfinvoke component="TestCase" method="createResult" returnvariable="r">
			</cfinvoke>
			
			<cfset startTime = getTickCount()>
			
			<cfif IsDefined("ARGUMENTS.test.suite")>
				<cfset ARGUMENTS.test.suite().run( r ) />
			<cfelse>
				<cfset ARGUMENTS.test.run( r ) />
			</cfif>
			
			<cfset endTime = getTickCount()>
			<cfset execTime = endTime-startTime>
		</cfsilent>
		
		<cfoutput>
			
			<cfif styled>
				<cfsavecontent variable="css">
				<style type="text/css" media="all">

					##cfunit-testresults {
						padding: auto;
						margin: 2em;
						font-family: Verdana, Geneva, san-serif;
						font-size: x-small;
						text-align: left;
					}
					
					##cfunit-testresults table tr {
						padding: 0;
						margin: 0;
					}
					
					ul##cfunit-error-list,
					ul##cfunit-failure-list
					{
					 	list-style: none;
					 	padding: 0px;
					 	margin: 0px;
					}
					
					ul##cfunit-error-list > li,
					ul##cfunit-failure-list > li
					{
						padding: 0.5em;
					}
					
					ul##cfunit-error-list td.header {
						background: ##f04a42;
					}

					ul##cfunit-failure-list td.header {
						background: ##f1ab41;
					}
					
					##cfunit-testresults table th {
						border: 1px solid black;
						padding: 0.8em;
						margin: 0;
						text-align:center;
					}
					##cfunit-testresults table td {
						border: 1px solid black;
						padding: 0.8em;
						margin: 0;
						vertical-align: top;
						font-family: Verdana, Geneva, san-serif;
						font-size: x-small;
					}

					.error table##cfunit-results  {
						border: 1px solid ##660000;
						background: ##f04a42;
					}
					
					.failure table##cfunit-results  {
						border: 1px solid ##660000;
						background: ##f1ab41;
					}

					.success table##cfunit-results  {
						border: 1px solid ##006600;
						background: ##66cc66;
						/*background: ##a6a6ff;*/
					}

					table##cfunit-results td{
						width:33%;
						text-align:center;
					}
				</style>			
				</cfsavecontent>
				<cfhtmlhead text="#css#">
			</cfif>
			
			<cfif r.errorCount() GT 0>
				<cfset styleType = "error">
				<cfset msg = "Error">
			<cfelseif r.failureCount() GT 0>
				<cfset styleType = "failure">
				<cfset msg = "Failure">
			<cfelse>
				<cfset styleType = "success">
				<cfset msg = "Success">
			</cfif>
		
			<div id="cfunit-testresults" class="#styleType#">
			<h2 id="status">#msg#</h2>
			<table id="cfunit-results">
				<tr>
					<th>Tests</th>
					<th>Errors</th>
					<th>Failures</th>
				</tr>
				<tr>
					<td>#r.runCount()#</td>
					<td>#r.errorCount()#</td>
					<td>#r.failureCount()#</td>
				</tr>
			</table>
			<cfif ARGUMENTS.verbose>
			Execution Time: #execTime# ms
				<cfif NOT r.wasSuccessful()>
					<cfif r.errorCount()>
						<ul id="cfunit-error-list">
							<cfset it = r.errors()>
							<cfloop condition="#it.hasNext()#">
								<cfset count = count+1 />
								<cfset thisMessage = it.next()>
								<li><h3>Error #count#</h3>
									#outputError(thisMessage)#
									<!--- #HTMLEditFormat( thisMessage.getString() )#: #HTMLEditFormat( thisMessage.thrownException().Detail )# [<a href="javascript:alert('#trace#')">view trace</a>] --->
								</li>
							</cfloop>
						</ul>
					</cfif>
										
					<cfif r.failureCount()>
						<cfset count = 0 />
						<ul id="cfunit-failure-list">
							<cfset it = r.failures()>
							<cfloop condition="#it.hasNext()#">
								<cfset count = count+1 />
								<cfset thisMessage = it.next()>
								<li><h3>Failure #count#</h3>
									#outputError(thisMessage)#
									<!--- #HTMLEditFormat( thisMessage.getString() )# --->
								</li>
							</cfloop>
						</ul>
					</cfif>
					
				</cfif>
			</cfif>
			</div>
		</cfoutput>
		
	</cffunction>
	
	<cffunction name="outputError" hint="outputs the error on screen" access="private" returntype="void" output="true">
		<cfargument name="testFailure" hint="The test failure" type="TestFailure" required="Yes">

		<cfset var iterator = arguments.testFailure.thrownException().tagContext.iterator() />
		<cfset var context = 0 />
		
		<table>
			<tr>
				<td class="header">Test</td>
				<td>#arguments.testFailure.failedTest().getString()#</td>
			</tr>
			<tr>
				<td class="header">Message</td>
				<td>#HTMLEditFormat( arguments.testFailure.thrownException().message )#</td>
			</tr>
			<cfif Len(arguments.testFailure.thrownException().detail)>
			<tr>
				<td class="header">Detail</td>
				<td>#HTMLEditFormat( arguments.testFailure.thrownException().detail )#</td>
			</tr>
			</cfif>
			<cfif StructKeyExists(arguments.testFailure.thrownException(), "sql")>
			<tr>
				<td class="header">SQL</td>
				<td>#arguments.testFailure.thrownException().sql#
			        <cfif StructKeyExists(arguments.testFailure.thrownException(), "where")><p>#replaceNoCase(arguments.testFailure.thrownException().where, ",(", "<br/>(", "all")#</p></cfif>
				</td>
			</tr>
			</cfif>
			<!--- if it's a assert error, we don't need this stuff --->
			<cfif NOT arguments.testFailure.thrownException().type eq "AssertionFailedError">
			<tr>
				<td class="header">Type</td>
				<td>#arguments.testFailure.thrownException().type#</td>
			</tr>
			<tr>
				<td class="header">Tag Context</td>
				<td>
					<ol>
						<cfloop condition="#iterator.hasNext()#">
							<cfset context = iterator.next()>
							<li>
								#context.template#:#context.line#
							</li>
						</cfloop>
					</ol>
				</td>
			</tr>
			</cfif>

		</table>
	</cffunction>
	
	<cffunction name="textrun" access="public" output="No" returntype="string">
		<cfargument name="test" required="Yes" type="Test">
		<cfargument name="name" required="Yes" type="string">
		<cfargument name="verbose" required="No" default="true" type="boolean">
		
		<cfset var content = ""/>
		<cfset var status = "Unknown"/>
		<cfset var messages = ArrayNew(1)/>
		<cfset var startTime = 0/>
		<cfset var endTime = 0/>
		<cfset var execTime = 0/>
		<cfset var it = 0 />
		<cfset var thisMessage = "" />
		
		<cfsilent>
			<cfinvoke component="TestCase" method="createResult" returnvariable="results">
			</cfinvoke>
			
			<cfset startTime = getTickCount()>
			
			<cfif IsDefined("ARGUMENTS.test.suite")>
				<cfset ARGUMENTS.test.suite().run( results ) />
			<cfelse>
				<cfset ARGUMENTS.test.run( results ) />
			</cfif>
			
			<cfset endTime = getTickCount()>
			<cfset execTime = endTime-startTime>
			
			<cfif results.errorCount() GT 0>
				<cfset status = "Error" />
			<cfelseif results.failureCount() GT 0>
				<cfset status = "Failure" />
			<cfelse>
				<cfset status = "Success" />
			</cfif>
			
			
			<cfif NOT results.wasSuccessful()>
				
				<cfif results.errorCount()>
					<cfset it = results.errors()>
					<cfloop condition="#it.hasNext()#">
						<cfset thisMessage = it.next()>					
						<cfset ArrayAppend(messages, "[error] #thisMessage.getString()#: #thisMessage.thrownException().Detail#") />
					</cfloop>
				</cfif>
				
				<cfif results.failureCount()>
					<cfset it = results.failures()>
					<cfloop condition="#it.hasNext()#">
						<cfset thisMessage = it.next()>
						<cfset ArrayAppend(messages, "[failure] #thisMessage.getString()#") />
					</cfloop>
				</cfif>
			</cfif>
			
			
		</cfsilent>
			
		<cfsavecontent variable="content"><cfoutput>
#status#<cfif ARGUMENTS.verbose>
Execution Time: #execTime# ms
#ArrayToList(messages, Chr(10) )#</cfif>
		</cfoutput></cfsavecontent>
		
		<cfreturn content />
		
	</cffunction>
	
	<cffunction name="getJSTrace" access="private" output="No" returntype="string">
		<cfargument name="exception" type="any" required="Yes">
		
		<cfset var tc = ARGUMENTS.exception.TagContext />
		<cfset var len = ArrayLen(tc) />
		<cfset var trace = "" />
		<cfset var i = 0 />
		<cfset var x = "" />
		<cfset var thisTemplate = "" />
		<cfset var thisID = "" />
		
		<cfloop from="1" to="#len#" index="i">
			<cfif tc[i].template CONTAINS "\CF-INF\cfcomponents\">
				<cfset x = Len(tc[i].template)-(FindNoCase("\CF-INF\cfcomponents\", tc[i].template)+20)>
				<cfset thisTemplate = Replace(Right(tc[i].template, x), "\", "." , "all")>
			<cfelse>
				<cfset thisTemplate = tc[i].template>
			</cfif>
			
			<cfif StructKeyExists(tc[i], "ID")>
				<cfset thisID = tc[i].ID & "--->">
			<cfelse>
				<cfset thisID = "--->">
			</cfif>
			
			<cfset trace = ListPrepend(trace, JSStringFormat(thisID)&JSStringFormat(thisTemplate)&":"&tc[i].line, "|")>
		</cfloop>

		<cfset trace = Replace(trace, "|", "\n\r", "all")>
		
		<cfreturn trace>
	</cffunction>
</cfcomponent>