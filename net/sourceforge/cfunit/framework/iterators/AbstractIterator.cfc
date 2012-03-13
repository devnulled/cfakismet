<cfcomponent displayname="AbstractIterator">

	<cfproperty name="MY" type="struct" hint="Protected and Inheritable Instance Structure" required="yes" default="StructNew()">
	<cfproperty name="MY.collection" type="any" hint="The collection being iterated through" required="yes" default="">
	<cfproperty name="MY.index" type="numeric" hint="The current index of the MY.collection" required="no" default="0">
	<cfproperty name="MY.length" type="numeric" hint="The length of MY.collection" required="no" default="0">
	<cfproperty name="MY.currentItem" type="any" hint="The item at the current index of MY.collection" required="no" default="">

	<cfset variables.my = structNew()>
	<cfset variables.my["collection"] = "">
	<cfset variables.my["index"] = 0>
	<cfset variables.my["length"] = 0>
	<cfset variables.my["currentItem"] = "">

	<cffunction name="init"  access="public" output="No" Hint="Initializes Iterator object // always returns this">
		<cfabort showerror="Error: This Method is Abstract and must be overridden">
	</cffunction>
	
	<cffunction name="hasNext" access="public" returntype="boolean">
		<cfif variables.my["length"] GTE variables.my["index"] + 1>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	<cffunction name="next" access="public" output="No" returntype="any">
		<cfabort showerror="Error: This Method is Abstract and must be overridden">
	</cffunction>

</cfcomponent>