<cfcomponent displayname="MyCFCTest" extends="net.sourceforge.cfunit.framework.TestCase">
	<cfproperty name="tempCFC" type="MyCFC">
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfset VARIABLES.tempCFC = CreateObject("component", "MyCFC").init()>
	</cffunction>
	
	<cffunction name="testAdd" returntype="void" access="public">
		<cfset result = VARIABLES.tempCFC.add()>
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="expected" value="#numberFormat(5.0)#">
			<cfinvokeargument name="actual" value="#numberFormat(result)#">
		</cfinvoke>
	</cffunction>
	
	<cffunction name="testSub" returntype="void" access="public">
		<cfset result = VARIABLES.tempCFC.sub()>
		<cfinvoke method="assertEquals">
			<cfinvokeargument name="expected" value="#numberFormat(1.0)#">
			<cfinvokeargument name="actual" value="#numberFormat(result)#">
		</cfinvoke>
	</cffunction>

</cfcomponent>
