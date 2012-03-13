<cfcomponent displayname="ArrayIterator" extends="AbstractIterator">

	<cffunction name="init" access="public" returntype="struct" output="No" hint="Initializes ArrayIterator object // always returns this for method chaining">
		<cfargument name="collection" type="array" required="true">
		
		<cfset variables.my["collection"] = arguments.collection>
		<cfset variables.my["length"] = arraylen( variables.my["collection"] )>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="next" access="public" output="No">
		<cfif this.hasNext()>
			<cfset variables.my["index"] = variables.my["index"] + 1>
			<cfset variables.my["currentItem"] = variables.my["collection"][variables.my["index"]]>
		</cfif>
		
		<cfreturn variables.my["currentItem"]>
	</cffunction>

</cfcomponent>