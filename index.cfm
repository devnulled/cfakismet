<!--- BH: Enter your BlogURL here --->
<cfset BlogURL = "" />
<!--- BH: Enter your API Key here --->
<cfset AkismetAPIKey = "NOT DEFINED" />
<cfset ApplicationName = "CFAkismet Unit Test" />


<html><head><title>Quick And Dirty CFAkismet Test Script</title></head><body>
<h1>Quick And Dirty CFAkismet Test Script</h1>

<p>Invoking CFAkismet component...</p>
<cfset a = CreateObject("component", "com.devnulled.cfakismet.CFAkismet").init() />

<p>Setting Required Settings for CFAkismet...</p>
<cfset a.setBlogURL(BlogURL) />
<cfset a.setKey(AkismetAPIKey) />
<cfset a.setApplicationName(ApplicationName) />

<p>Verifying API Key <cfoutput>#AkismetAPIKey#</cfoutput>...</p>
<cfset KeyValid = a.verifyKey() />

<cfif KeyValid>
	<p>API Key is valid</p>
	
	<!--- Test a comment--->
	<p>Generating test comment...</p>
	
	
	<cfset args = StructNew() />
	<cfset args.CommentAuthor  = "viagra-test-123" />
	<cfset args.CommentAuthorEmail  = "spammer@jerkbag.com" />
	<cfset args.CommentAuthorURL  = "http://suckswang.com" />
	<cfset args.CommentContent  = "Spammy McSpammer" />
	<cfset args.Permalink  = BlogURL & "/entry/123" />
	
	<cfdump var="#args#" label="Test Comment">
	
	<p>Checking to see if this generated comment is spam...</p>
	<cfset CommentIsSpam = a.isCommentSpam(ArgumentCollection=args) />
	
	<cfif CommentIsSpam>
		<p>Comment <strong>is</strong> Spam</p>
	<cfelse>
		<p>Comment <strong>is not</strong> Spam</p>
	</cfif>
	
	<cfset args.CommentAuthor = "Spammy McSpammer">
	<p>Submitting Spam to Akismet...</p>
	
	<cfset a.SubmitSpam(ArgumentCollection=args) />
	
	<p>Spam Submission Complete</p>
<cfelse>
	<p>API Key is invalid</p>
</cfif>
<p>Testing Complete!</p>
</body></html>