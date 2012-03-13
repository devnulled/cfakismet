<cfsilent>
	<cfparam name="ATTRIBUTES.firstAttribute" default="Not Given" />
	<cfparam name="ATTRIBUTES.secondAttribute" default="Not Given" />
	<cfparam name="ATTRIBUTES.lastAttribute" default="Not Given" />
</cfsilent>

<cfoutput>
	<h2>Hello World From Module!</h2>
	<ol>
		<li>#ATTRIBUTES.firstAttribute#</li>
		<li>#ATTRIBUTES.secondAttribute#</li>
		<li>#ATTRIBUTES.lastAttribute#</li>
	</ol>
</cfoutput>