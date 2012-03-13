<cfcomponent displayname="QueryIterator" extends="AbstractIterator">

	<cffunction name="init" access="public"returntype="struct" output="No" hint="Initializes QueryIterator object // always returns this for method chaining">
		<cfargument name="collection" type="query" required="true">
		
		<cfset variables.my["collection"] = duplicate(arguments.collection) />
		<cfset variables.my["length"] = variables.my["collection"].recordcount />
		<cfset variables.my["currentItem"] = structNew() />
		<cfset variables.my["columns"] = listToArray(variables.my["collection"].columnList) />
		<cfset variables.my["columnCount"] = arraylen( variables.my["columns"] ) />
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="next" access="public" output="No">
		<!--- Initialize local variables --->
		<cfset var fieldName = "" />
		<cfset var fieldIndex = 0 />
		
		<!--- CHECK: Does this collection have a next element? --->
		<cfif this.hasNext()>
			<!--- Increment the collections index --->
			<cfset variables.my["index"] = variables.my["index"] + 1>
			
			<!--- LOOP: Over each column in the query to get each field --->
			<cfloop from="1" to="#variables.my.columnCount#" index="fieldIndex">
				<!--- Get the current column's (field) name --->
				<cfset fieldName = variables.my["columns"][fieldIndex] />
				<!--- Set the current item's field value to the value from the original query --->
				<cfset variables.my["currentItem"][ fieldName ] = variables.my["collection"][ fieldName ][variables.my["index"]]>
			</cfloop>
		</cfif>
		
		<!--- Retutn the current item --->
		<cfreturn variables.my["currentItem"]>
	</cffunction>

</cfcomponent>