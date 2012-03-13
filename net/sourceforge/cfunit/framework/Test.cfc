<!---
*** CFUnit Runner File                                         ***
*** http://cfunit.sourceforge.net                              ***

*** @verion 1.0                                                ***
***          Robert Blackburn (http://www.rbdev.net)           ***
***          Initial Creation                                  ***


--->
<cfcomponent extends="Assert" hint="A <em>Test</em> can be run and collect its results.">
	<cffunction name="countTestCases" access="public" returntype="numeric" hint="Counts the number of test cases that will be run by this test.">
		<cfthrow message="Method countTestCases() must be overriden" type="AbstractMethod"> 
	</cffunction>
	
	<cffunction name="run" access="public" returntype="TestResult" hint="Runs a test and collects its result in a TestResult instance.">
		<cfthrow message="Method run() must be overriden" type="AbstractMethod"> 
	</cffunction>
	
			
	<cfscript>
	/**
	 * Concatenates two arrays.
	 * 
	 * @param a1 	 The first array. 
	 * @param a2 	 The second array. 
	 * @return Returns an array. 
	 * @author Craig Fisher (craig@altainetractive.com) 
	 * @version 1, September 13, 2001 
	 */
	function ArrayConcat(a1, a2){
		var i=1;
		if ((NOT IsArray(a1)) OR (NOT IsArray(a2))) {
			writeoutput("Error in <Code>ArrayConcat()</code>! Correct usage: ArrayConcat(<I>Array1</I>, <I>Array2</I>) -- Concatenates Array2 to the end of Array1");
			return 0;
		}
		for (i=1;i LTE ArrayLen(a2);i=i+1) {
			ArrayAppend(a1, a2[i]);
		}
		return a1;
	}
	</cfscript>
</cfcomponent>