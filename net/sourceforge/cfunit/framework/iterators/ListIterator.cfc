<cfcomponent displayname="ListIterator" extends="AbstractIterator">

	<cfset variables.my["delimiters"] = "">
	
	<cffunction name="init" access="public" output="No" hint="Initializes ListIterator object // always returns this for method chaining" returntype="struct">
		<cfargument name="collection" type="string" required="true">
		<cfargument name="delimiters" type="string" required="false" default=",">
		
		<cfset variables.my["collection"] = arguments.collection>
		<cfset variables.my["delimiters"] = arguments.delimiters>
		<cfset variables.my["length"] = listlen(variables.my["collection"], variables.my["delimiters"])>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="next" access="public" output="No">
		<cfif this.hasNext()>
			<cfset variables.my["index"] = variables.my["index"] + 1>
			<cfset variables.my["currentItem"] = ListGetAt(variables.my["collection"], variables.my["index"] , variables.my["delimiters"])>
		</cfif>
		<cfreturn variables.my["currentItem"]>
	</cffunction>

</cfcomponent>