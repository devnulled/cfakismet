<!--- 
	VarScopeChecker.cfc
	
	Parses a .cfc file, .cfm file or raw block of text looking for non-var-scoped local variables.
	
	Author: Seth Petry-Johnson

	Version: 1.01
	Change log:
		02/03/2006	created 
		02/08/2006	no longer giving false positives on var-scoped structs using array notation
--->

<cfcomponent 
	displayName="VarScopeChecker" 
	output="false"
	hint="Parses a .cfc file, .cfm file or raw block of text looking for non-var-scoped local variables.">

<!-----------------------------
	Constructors
------------------------------->
<!--- init() --->
<cffunction name="init" returnType="VarScopeChecker" access="public" output="false" 
	hint="Constructor for this component.">

	<cfreturn this />
</cffunction>


<!----------------------------------------------------------------------------------
	PUBLIC INTERFACE
----------------------------------------------------------------------------------->
<!--- check( fileOrDirectory ) --->
<cffunction name="check" returnType="array" access="public" output="false" 
	hint="Accepts a string that is an absolute path to a file or a directory. If a directory name is given then all .cfm and .cfc files 
		  in that directory are examined. Returns an array of structs describing any local variables that were found but not properly 
		  var-scoped.  Each struct has the following keys: <br />
		  	 .filename = a STRING that is the name of the file with the offending variable<br />
		  	 .function = a STRING that is the name of the function containing the variable<br />
		     .variable = a STRING that is the name of a non-var-scoped local variable">

	<cfargument name="fileOrDirectory" type="string" required="yes" hint="An absolute path to either a file or directory." />

	<cfset var local = StructNew() />
	<cfset var i = 0 />
	<cfset var j = 0 />
	<cfset var k = 0 />
	
	<!--- determine what type of input we have and create an array of fully qualified paths to the file(s) to scan --->
	<cfset local.filesToScan = ArrayNew(1) />
	<cfif isAbsoluteDirectory(arguments.fileOrDirectory)>
		<cfset local.filesToScan = recursiveFileList(arguments.fileOrDirectory, "*.cf[c|m]") />
	<cfelse>
		<cfset ArrayAppend(local.filesToScan, arguments.fileOrDirectory) />
	</cfif>

	<!--- init the array to hold all problems we find --->
	<cfset local.errors = ArrayNew(1) />

	<!--- process each file --->
	<cfloop index="i" from="1" to="#ArrayLen(local.filesToScan)#">
		<cffile action="read" file="#local.filesToScan[i]#" variable="local.code" />
	
		<!--- create an array of strings that are the code blocks --->
		<cfset local.functions = getFunctionArray(local.code) />
		
		<!--- check each function definition for non-var scoped variables --->
		<cfloop index="j" from="1" to="#ArrayLen(local.functions)#">
			<cfset local.thisFunct = local.functions[j] />
			<cfset local.thisFunctName = getFunctionName(local.thisFunct) />
			
			<!--- get the body of the function, which is anything after the argument declarations --->
			<cfset local.body = getFunctionBody(local.thisFunct) />
			
			<!--- get an array of var-scoped variables --->
			<cfset local.varSectionVars = getVarScopedVariables(getVarSection(local.body)) />
		
			<!--- get an array of non-var scoped variables set later in the code --->
			<cfset local.bodyVars = getVariablesSetInBody(local.body) />
			
			<!--- 
				create an array of locally scoped variables set in the body of the function that are not declared
				in the var scoping section of the function
			--->
			<cfset local.dangerVars = getNonVarScopedLocalVariables(local.varSectionVars, local.bodyVars) />
			<cfloop index="k" from="1" to="#ArrayLen(local.dangerVars)#">
				<cfset local.thisError = StructNew() />
				<cfset local.thisError["filename"] =  local.filesToScan[i] />
				<cfset local.thisError["function"] =  local.thisFunctName />
				<cfset local.thisError["variable"] = local.dangerVars[k] />
				<cfset ArrayAppend(local.errors, local.thisError) />
			</cfloop>
		</cfloop>
	</cfloop>

	<cfreturn local.errors />
</cffunction>


<!----------------------------------------------------------------------------------
	PRIVATE METHODS
----------------------------------------------------------------------------------->
<!---
	getFunctionArray( codeBlock )
--->
<cffunction name="getFunctionArray" returnType="array" access="private" output="false" 
	hint="Accepts a block of code and returns an array of strings containing the function definitions from the code.">

	<cfargument name="code" type="string" required="yes" hint="The block of code to analyze" />

	<cfset var local = StructNew() />
	<cfset local.functionArray = ArrayNew(1) />

	<!--- 
		The > character is used as a tag terminator but can also appear inside string literals.  To simplify processing
		we first replace all occurances of this character that occur between single or double quotes, then we do
		whatever processing we need, and then we swap the > back into the string literals at the end
	--->
	<cfset local.code = ReplaceInStringLiterals(arguments.code, ">", "%GT_PLACEHOLDER%") />
	
	<cfset local.startAt = 1 />
	<cfloop condition="#local.startAt# LT #Len(local.code)#">
		<cfset local.functionMatches = ReFindNoCase("<cffunction[^>]*>.*?</cffunction>", local.code, local.startAt, true) />
		
		<cfif local.functionMatches.len[1] LTE 0>
			<cfbreak />
		<cfelse>
			<cfset local.thisFunction = Mid(local.code, local.functionMatches.pos[1], local.functionMatches.len[1]) />
			<cfset local.thisFunction = ReplaceInStringLiterals(local.thisFunction, "%GT_PLACEHOLDER%", ">") />
			<cfset ArrayAppend(local.functionArray, local.thisFunction) />
			<cfset local.startAt = local.functionMatches.pos[1] + local.functionMatches.len[1] />
		</cfif>
	</cfloop>
	
	<cfreturn local.functionArray />	
</cffunction>


<!---
	getFunctionBody( wholeFunction )
--->
<cffunction name="getFunctionBody" returnType="string" access="private" output="false" 
	hint="Accepts a string that contains a CF function declaration and returns a string of just the function body, which is everything
		  after the last argument declaration and before the closing cffunction tag.  Returns the input string if the function tags aren't found.">

	<cfargument name="wholeFunction" type="string" required="yes" hint="The function declaration to analyze" />

	<cfset var local = StructNew() />
	<cfset local.functionBody = arguments.wholeFunction />
	<cfset local.wholeFunction = ReplaceInStringLiterals(arguments.wholeFunction, ">", "%GT_PLACEHOLDER%") />

	<cfset local.bodyMatch = ReFindNoCase("(?x)
			<cffunction[^>]*>								## match the opening function tag		
			([[:space:]]*<cfargument[^>]*>[[:space:]]*)*	## match any number of optional arguments
			(.*?)											## this is the function body (the 2nd subexpression match)
			</cffunction>									## close the function tag
			", local.wholeFunction, 1, true) />

	<cfif ArrayLen(local.bodyMatch.len) EQ 3>
		<cfset local.functionBody = Mid(local.wholeFunction, local.bodyMatch.pos[3], local.bodyMatch.len[3]) />
		<cfset local.functionBody = ReplaceInStringLiterals(local.functionBody, "%GT_PLACEHOLDER%", ">") />
	</cfif>
	
	<cfreturn local.functionBody />
</cffunction>


<!---
	getFunctionName( wholeFunction )
--->
<cffunction name="getFunctionName" returnType="string" access="private" output="false" 
	hint="Accepts a string that contains a CF function declaration and returns a string that is the function name.">

	<cfargument name="wholeFunction" type="string" required="yes" hint="The function declaration to analyze" />

	<cfset var local = StructNew() />
	<cfset local.functionName = "" />

	<cfset local.matches = ReFindNoCase(".*<cffunction[^>]*name[[:space:]]*=[[:space:]]*""([a-zA-Z0-9_]+)""[^>]*>", arguments.wholeFunction, 1, true) />

	<cfif ArrayLen(local.matches.len) EQ 2>
		<cfset local.functionName = Mid(arguments.wholeFunction, local.matches.pos[2], local.matches.len[2]) />
	</cfif>
	
	<cfreturn local.functionName />
</cffunction>


<!---
	getVarSection( wholeFunction )
--->
<cffunction name="getVarSection" returnType="string" access="private" output="false" 
	hint="Accepts a string that contains a CF function declaration and returns a string of just the local variable declarations.">

	<cfargument name="wholeFunction" type="string" required="yes" hint="The function declaration to analyze" />

	<cfset var local = StructNew() />
	<cfset var reCOMMENT = "(<!---.*?--->)" />
	<cfset local.varSection = "" />
	
	<!--- get just the function "body", which is the function minus the function and argument tags --->
	<cfset local.body = getFunctionBody(arguments.wholeFunction) />
	<!--- 
		We analyze the block of text looking for <cfset> statements at the start of the code.  After each match 
		we cut the matched string from the remaining block of text, add it to the var section string, and repeat.  We
		do this until we don't find a <cfset> statement at the start of the remaining text which indicates the var section
		is over.

		The <cfset> regexp uses the ">" to signal the end of a cfset statement so we need to account for string 
		literals that contain this character.  To do this we replace any ">" inside a string literal with a 
		placeholder string of "%GT_PLACEHOLDER%", then swap the ">" back in after the regexp does its work.
	--->
	<cfset local.remainingText = ReplaceInStringLiterals(local.body, ">", "%GT_PLACEHOLDER%") />
	<cfloop condition="#Len(local.remainingText)# GT 0">
		<cfset local.matches = ReFindNoCase("^[[:space:]]*#reCOMMENT#*[[:space:]]*<cfset var [a-zA-Z0-9_\.\[\]""']+[[:space:]]*=[^>]+>", local.remainingText, 1, true) />
		
		<cfif local.matches.len[1] LTE 0>
			<cfbreak />
		<cfelse>
			<cfset local.varSection = local.varSection & Left(local.remainingText, local.matches.len[1]) />
			<cfif Len(local.remainingText) EQ local.matches.len[1]>
				<!--- there's nothing left to check! --->
				<cfbreak />
			<cfelse>
				<cfset local.remainingText = Right(local.remainingText, Len(local.remainingText) - local.matches.len[1]) />
			</cfif>
		</cfif>
	</cfloop>
	<cfset local.varSection = ReplaceInStringLiterals(local.varSection, "%GT_PLACEHOLDER%", ">") />
	
	<cfreturn local.varSection />
</cffunction>


<!---
	getVarScopedVariables( functionBody )
--->
<cffunction name="getVarScopedVariables" returnType="array" access="private" output="false" 
	hint="Accepts a string that contains a CF function body and returns an array of all var-scoped variables defined in the function.">

	<cfargument name="functionBody" type="string" required="yes" hint="The function body to analyze" />

	<cfset var local = StructNew() />
	<cfset local.vars = ArrayNew(1) />
	
	<!--- look at the var scope section of the body only --->
	<cfset local.varSection = getVarSection(arguments.functionBody) />

	<!---
		This code will actually find any variable that is var-scoped, even if it doesn't appear at the top of the
		function declaration like is required.  However, the CF parser will scream about that case so we don't need
		to worry about it too much here
	--->
	<cfset local.startAt = 1 />
	<cfloop condition="#local.startAt# LT #Len(local.varSection)#">
		<cfset local.varMatches = ReFindNoCase("<cfset +var +([a-zA-Z0-9_\.\[\]]+) +=", local.varSection, local.startAt, true) />
		
		<cfif ArrayLen(local.varMatches.len) NEQ 2>
			<cfbreak />
		<cfelse>
			<cfset ArrayAppend(local.vars, Mid(local.varSection, local.varMatches.pos[2], local.varMatches.len[2])) />
			<cfset local.startAt = local.varMatches.pos[1] + local.varMatches.len[1] />
		</cfif>
	</cfloop>
	
	<cfreturn local.vars />
</cffunction>


<!---
	replaceInStringLiterals( string, replaceString, withString )
--->
<cffunction name="replaceInStringLiterals" returnType="string" access="private" output="false" 
	hint="Replaces all occurances of a given string with another, but only if that string is found within a string literal (i.e. between double or single quotes)">

	<cfargument name="string" type="string" required="yes" hint="The string to search" />
	<cfargument name="replaceString" type="string" required="yes" hint="The string to replace (if it occurs within a string literal)" />
	<cfargument name="withString" type="string" required="yes" hint="The string to replace with" />

	<cfset var local = StructNew() />
	<cfset local.newString = "" />
	
	<!--- 
		Starting at the beginning of the source string we grab as many characters as possible that includes at most 
		one pair of quotes.  We then do the replacement within that set of quotes and add the resulting string to 
		a temp variable and then repeat.  We do this until the entire source string has been parsed, one pair of quotes
		at a time.  We then return the temp string 
	--->
	<cfset local.remainingText = arguments.string />
	<cfloop condition="#Len(local.remainingText)# GT 0">
		<cfset local.matches = ReFindNoCase("^[^""]*""[^""]*""", local.remainingText, 1, true) />
		
		<cfif local.matches.len[1] LTE 0>
			<!--- add the remaining text to the temp string --->
			<cfset local.newString = local.newString & local.remainingText />
			<cfbreak />
		<cfelse>
			<!--- 
				chop off any characters leading up the string literal, then do all the replacements
				within the leading and trailing quote marks, then string everything back together
			--->
			<cfset local.thisMatch = Left(local.remainingText, local.matches.len[1]) />
			<cfset local.leadingChars = ReReplaceNoCase(local.thisMatch, "^(.*)"".*""$", "\1") />
			<cfset local.stringLiteralOnly = ReReplaceNoCase(local.thisMatch, "^.*""(.*)""$", "\1") />
			<cfset local.postReplace = local.leadingChars & """" & Replace(local.stringLiteralOnly, arguments.replaceString, arguments.withString, "ALL") & """" />
			<cfset local.newString = local.newString & local.postReplace />
			<cfset local.remainingText = Right(local.remainingText, Len(local.remainingText) - local.matches.len[1]) />
		</cfif>
	</cfloop>
	
	<cfreturn local.newString />
</cffunction>


<!---
	getVariablesSetInBody( wholeFunction )
--->
<cffunction name="getVariablesSetInBody" returnType="array" access="private" output="false" 
	hint="Accepts a string that contains a CF function declaration and returns an array of all variables declared using cfset, cfquery or cfloop
		  in the body of that funtion.">

	<cfargument name="wholeFunction" type="string" required="yes" hint="The function to analyze" />

	<cfset var local = StructNew() />
	<cfset local.vars = ArrayNew(1) />
	
	<!--- get just the body section of this function, minus the var-scoping section --->
	<cfset local.body = getFunctionBody(arguments.wholeFunction) />
	<cfset local.varSection = getVarSection(local.body) />
	<cfif Len(Trim(local.varSection)) GT 0>
		<cfset local.body = Replace(local.body, getVarSection(local.body), "") />
	</cfif>
	
	<!--- get all variables created via <cfset> --->
	<cfset local.startAt = 1 />
	<cfloop condition="#local.startAt# LT #Len(local.body)#">
		<cfset local.varMatches = ReFindNoCase("<cfset[[:space:]]+([a-zA-Z0-9_\.\[\]""']+)[[:space:]]*=", local.body, local.startAt, true) />
		<cfif ArrayLen(local.varMatches.len) NEQ 2>
			<cfbreak />
		<cfelse>
			<cfset ArrayAppend(local.vars, Mid(local.body, local.varMatches.pos[2], local.varMatches.len[2])) />
			<cfset local.startAt = local.varMatches.pos[1] + local.varMatches.len[1] />
		</cfif>
	</cfloop>
	
	<!--- get all variables created via <cfquery> --->
	<cfset local.startAt = 1 />
	<cfloop condition="#local.startAt# LT #Len(local.body)#">
		<cfset local.varMatches = ReFindNoCase("<cfquery[^>]*name=""([a-zA-Z0-9_\.\[\]""']+)""[^>]*>", local.body, local.startAt, true) />
		<cfif ArrayLen(local.varMatches.len) NEQ 2>
			<cfbreak />
		<cfelse>
			<cfset ArrayAppend(local.vars, Mid(local.body, local.varMatches.pos[2], local.varMatches.len[2])) />
			<cfset local.startAt = local.varMatches.pos[1] + local.varMatches.len[1] />
		</cfif>
	</cfloop>

	<!--- get all index variables created via <cfloop> --->
	<cfset local.startAt = 1 />
	<cfloop condition="#local.startAt# LT #Len(local.body)#">
		<cfset local.varMatches = ReFindNoCase("<cfloop[^>]*index=""([a-zA-Z0-9_\.\[\]""']+)""[^>]*>", local.body, local.startAt, true) />
		<cfif ArrayLen(local.varMatches.len) NEQ 2>
			<cfbreak />
		<cfelse>
			<cfset ArrayAppend(local.vars, Mid(local.body, local.varMatches.pos[2], local.varMatches.len[2])) />
			<cfset local.startAt = local.varMatches.pos[1] + local.varMatches.len[1] />
		</cfif>
	</cfloop>

	<cfreturn local.vars />
</cffunction>


<!--- 
	getNonVarScopedLocalVariables( arrayOfVarScope, arrayOfBodyVars )
--->
<cffunction name="getNonVarScopedLocalVariables" returnType="array" access="private" output="false" 
	hint="Accepts two arrays: the first is an array of all vars set in the var scope, the second is an array of all 
		  variables set in the body of a function.  This method compares the two and returns an array of all variables
		  set in the function body that are not var scoped and do not belong to the 'variables' or 'this' scopes.  (In other
		  words, it returns an array of all variables that should be var scoped and are not)">

	<cfargument name="arrayOfVarScope" type="array" required="yes" hint="The array of var-scoped variable names" />
	<cfargument name="arrayOfBodyVars" type="array" required="yes" hint="The array of variables set in a function body" />

	<cfset var local = StructNew() />
	<cfset var i = 0 />

	<cfset local.dangerVars = ArrayNew(1) />
	
	<cfset local.varScopeList = ArrayToList(arguments.arrayOfVarScope) />
	<cfloop index="i" from="1" to="#ArrayLen(arguments.arrayOfBodyVars)#">
		<cfset local.thisVar = arguments.arrayOfBodyVars[i] />
		<cfset local.thisVarNeedsFlagged = True />

		<cfif (NOT ReFindNoCase("^variables\.", local.thisVar))
				AND (NOT ReFindNoCase("^this\.", local.thisVar))
				AND (NOT ReFindNoCase("^arguments\.", local.thisVar))
				AND (NOT ReFindNoCase("^application\.", local.thisVar))
				AND (NOT ReFindNoCase("^session\.", local.thisVar))
				AND (NOT ReFindNoCase("^request\.", local.thisVar))
				AND NOT ListFindNoCase(local.varScopeList, local.thisVar)
				AND NOT ArrayFind(local.dangerVars, local.thisVar)>

			<!--- 
				If a variable is a member of a nested scope, like a structure or a query element, then
				only flag it as dangerous if the parent node (i.e. the leftmost section of the var name)
				is not var scioed
			--->
			<!--- check for dot notation --->
			<cfif (ListLen(local.thisVar, ".") GTE 2) AND ListFindNoCase(local.varScopeList, ListFirst(local.thisVar, "."))>
				<cfset local.thisVarNeedsFlagged = False />

			<!--- check for array notation --->
			<cfelseif (ListLen(local.thisVar, "[") GTE 2) AND ListFindNoCase(local.varScopeList, ListFirst(local.thisVar, "["))>
				<cfset local.thisVarNeedsFlagged = False />

			<cfelse>
				<cfset local.thisVarNeedsFlagged = True />
			</cfif>
		<cfelse>
			<cfset local.thisVarNeedsFlagged = False />
		</cfif>
		
		<cfif local.thisVarNeedsFlagged>
			<cfset ArrayAppend(local.dangerVars, local.thisVar) />
		</cfif>
	</cfloop>

	<cfreturn local.dangerVars />
</cffunction>


<!--- 
	isAbsoluteDirectory( string )
--->
<cffunction name="isAbsoluteDirectory" returnType="boolean" access="private" output="false" 
	hint="Accepts a string and returns TRUE if it represents a valid, absolute path to a directory or FALSE otherwise.">

	<cfargument name="path" type="string" required="yes" hint="The string to test" />

	<cfreturn DirectoryExists(arguments.path) />
</cffunction>


<!--- 
	isRelativeDirectory( string )
--->
<cffunction name="isRelativeDirectory" returnType="array" access="private" output="false" 
	hint="Accepts a string and returns TRUE if it represents a valid, relative path to a directory or FALSE otherwise.">

	<cfargument name="path" type="string" required="yes" hint="The string to test" />

	<cfreturn false />
</cffunction>


<!---
	recursiveFileList( directory, [filter] )
--->
<cffunction name="recursiveFileList" returnType="array" access="private" output="false" 
	hint="Accepts an absolute directory path and an optional filter and returns an array of all files matching that filter
		  in the specified directory and its sub-directories.">

	<cfargument name="directory" type="string" required="yes" hint="An absolute path to the directory to list" />
	<cfargument name="filter" type="string" default="" hint="An optional filename extension filter (i.e. '*.cfm')" />

	<cfset var filesToReturn = ArrayNew(1) />
	<cfset var dirList = 0 />
	<cfset var hasFilter = Len(Trim(arguments.filter)) GT 0 />
	
	<!--- add a trailing slash to the directory name if needed --->
	<cfif Find("\", arguments.directory) AND NOT ReFind(".*\$", arguments.directory)>
		<cfset arguments.directory = arguments.directory & "\" />
	<cfelseif Find("/", arguments.directory) AND NOT ReFind(".*/$", arguments.directory)>
		<cfset arguments.directory = arguments.directory & "/" />
	</cfif>

	<!--- 
		this needs to run on MX 6.1 so we can't use the "recurse" option of cfdirectory. I worry
		a little bit about doing the recursion this way... with a lot of nested directories there will
		be a lot of duplicate()ed arrays and a lot of temporary arrays thrown away.
		
		Also, if a filter is given then directory names aren't returned, so its easier to get all files
		in the directory and then compare the filter against each file in the result query
	--->
	<cfdirectory action="list" name="dirList" directory="#arguments.directory#" />
	<cfloop query="dirList">
		<cfif dirList.type EQ "dir">
			<cfset filesToReturn = ArrayAppendArray(filesToReturn, recursiveFileList(arguments.directory & dirList.name, arguments.filter)) />
		<cfelseif (NOT hasFilter) OR ReFindNoCase(".*\." & ListLast(arguments.filter, ".") & "$", dirList.name)>
			<cfset ArrayAppend(filesToReturn, arguments.directory & dirList.name) />
		</cfif>
	</cfloop>
	<cfreturn filesToReturn />
</cffunction>


<!---
	arrayAppendArray( baseArray, arrayToAdd )
--->
<cffunction name="arrayAppendArray" returnType="array" access="private" output="false" 
	hint="Accepts two arrays, appends all elements from the second onto the first, and then returns the result.">

	<cfargument name="baseArray" type="array" required="yes" hint="The array to append to" />
	<cfargument name="arrayToAdd" type="array" required="yes" hint="The array to append" />

	<cfset var newArray = Duplicate(arguments.baseArray) />
	<cfset var i = 0 />
	
	<cfloop index="i" from="1" to="#ArrayLen(arguments.arrayToAdd)#">
		<cfset ArrayAppend(newArray, arguments.arrayToAdd[i]) />
	</cfloop>

	<cfreturn newArray />
</cffunction>


<!---
	arrayFind( array, value )
--->
<cffunction name="arrayFind" returnType="numeric" access="private" output="false" 
	hint="Accepts an array and a value, returns the index of that array in which the value is first found.  Returns 0 if the value is not found.">

	<cfargument name="array" type="array" required="yes" hint="The array to search" />
	<cfargument name="value" type="any" required="yes" hint="The value to search for" />

	<cfset var foundAt = 0 />
	<cfset var i = 0 />
	<cfloop index="i" from="1" to="#ArrayLen(arguments.array)#">
		<cfif arguments.array[i] EQ arguments.value>
			<cfset foundAt = i />
			<cfbreak />
		</cfif>
	</cfloop>

	<cfreturn foundAt />
</cffunction>


</cfcomponent>