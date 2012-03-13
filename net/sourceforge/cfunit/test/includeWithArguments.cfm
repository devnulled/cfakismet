<cfsilent>
	<cfparam name="test0" default="NOT AVAILABLE" type="string" />
	<cfparam name="VARIABLES.test1" default="NOT AVAILABLE" type="string" />
	<cfparam name="URL.test2" default="NOT AVAILABLE" type="string" />
	<cfparam name="FORM.test3" default="NOT AVAILABLE" type="string" />
	<cfparam name="COOKIES.test4" default="NOT AVAILABLE" type="string" />
	<cfparam name="APPLICATION.test5" default="NOT AVAILABLE" type="string" />
	<cfparam name="REQUEST.test6" default="NOT AVAILABLE" type="string" />
</cfsilent>

<cfoutput>
<h2>Hello World!</h2>
<ul>
	<li>test0:#test0#</li>
	<li>VARIABLES.test1:#VARIABLES.test1#</li>
	<li>URL.test2:#URL.test2#</li>
	<li>FORM.test3:#FORM.test3#</li>
	<li>COOKIES.test4:#COOKIES.test4#</li>
	<li>APPLICATION.test5:#APPLICATION.test5#</li>
	<li>REQUEST.test6:#REQUEST.test6#</li>
</ul>
</cfoutput>