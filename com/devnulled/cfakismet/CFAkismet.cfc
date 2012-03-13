<!---
 CFAkismet

 Copyright 2006, Brandon Harper

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

--->

<cfcomponent hint="Provides Akismet anti-spam functionality for ColdFusion" output="false">
	
	<cfparam name="AkismetVersion" default="1.1" type="string" />
	<cfparam name="CFAkismetVersion" default="0.1" type="string">
	<cfparam name="VerifyKeyHost" default="rest.akismet.com" type="string" />
	<cfparam name="AkismetHost" default="rest.akismet.com" type="string" />
	
	<cfparam name="VerifyKeyPath" default="verify-key" type="string" />
	<cfparam name="SpamPath" default="submit-spam" type="string" />
	<cfparam name="HamPath" default="submit-ham" type="string" />
	<cfparam name="CommentCheckPath" default="comment-check" type="string" />
	<cfparam name="HTTPTimeout" default="10" type="numeric" />

	<cfparam name="isKeyVerified" default="false" type="boolean">
	
	<cffunction name="init" hint="Constructor" returntype="any" output="false">
		<cfset setBlogURL("") />
		<cfset setKey("") />
		<cfset setApplicationName("") />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getBlogURL" returntype="string" hint="Returns the value for BlogURL" output="false">
		<cfreturn Variables.BlogURL />
	</cffunction>

	<cffunction name="setBlogURL" returntype="void" hint="Sets the value for BlogURL" output="false">
		<cfargument name="BlogURL" hint="The value of BlogURL" type="string" required="true" />
		<cfset Variables.BlogURL = Arguments.BlogURL />
	</cffunction>

	<cffunction name="getKey" returntype="string" hint="Returns the value for Key" output="false">
		<cfreturn Variables.Key />
	</cffunction>

	<cffunction name="setKey" returntype="void" hint="Sets the value for Key" output="false">
		<cfargument name="Key" hint="The value of Key" type="string" required="true" />
		<cfset Variables.Key = Arguments.Key />
	</cffunction>
	
	<cffunction name="getApplicationName" returntype="string" hint="Returns the value for ApplicationName" output="false">
		<cfreturn Variables.ApplicationName />
	</cffunction>

	<cffunction name="setApplicationName" returntype="void" hint="Sets the value for ApplicationName" output="false">
		<cfargument name="ApplicationName" hint="The value of ApplicationName" type="string" required="true" />
		<cfset Variables.ApplicationName = Arguments.ApplicationName />
	</cffunction>
	
	<cffunction name="getUserIP" access="private" returntype="string" hint="Returns the value for UserIP" output="false">
		<cfreturn CGI.REMOTE_ADDR />
	</cffunction>

	<cffunction name="getReferrer" access="private" returntype="string" hint="Returns the value for Referrer" output="false">
		<cfreturn CGI.HTTP_REFERER />
	</cffunction>

	<cffunction name="getUserAgent" access="private" returntype="string" hint="Returns the value for UserAgent" output="false">
		<cfreturn CGI.HTTP_USER_AGENT />
	</cffunction>
	
	<cffunction name="getKeyURL" access="private" returntype="string" hint="Returns the value for KeyURL" output="false">
		<cfreturn "http://" & VerifyKeyHost & "/" & AkismetVersion & "/" & VerifyKeyPath />
	</cffunction>

	<cffunction name="getCommentURL" access="private" returntype="string" hint="Returns the value for CommentURL" output="false">
		<cfreturn "http://" & getKey() & "." & AkismetHost & "/" & AkismetVersion & "/" & CommentCheckPath />
	</cffunction>

	<cffunction name="getSpamURL" access="private" returntype="string" hint="Returns the value for SpamURL" output="false">
		<cfreturn "http://" & getKey() & "." & AkismetHost & "/" & AkismetVersion & "/" & SpamPath />
	</cffunction>

	<cffunction name="getHamURL" access="private" returntype="string" hint="Returns the value for HamURL" output="false">
		<cfreturn "http://" & getKey() & "." & AkismetHost & "/" & AkismetVersion & "/" & HamPath />
	</cffunction>
	
	<cffunction name="getCFAkismetUserAgent" access="private" returntype="string" hint="Returns the value for CFAkismetUserAgent" output="false">
		<cfreturn getApplicationName() &  " | " &  "CFAkismet/" & CFAkismetVersion />
	</cffunction>
	
	<cffunction name="verifyKey" returntype="boolean" hint="Validates the API Key" output="false">
		<cfset verifySettings() />
		<cfreturn sendKeyVerification() />
	</cffunction>
	
	<cffunction name="isCommentSpam" returntype="boolean" hint="Uses the Akisment API to determine whether or not a particular comment/trackback/etc is spam.  You should have already validated that the API Key was valid before calling this method" output="false">
		<cfargument name="CommentAuthor" type="string" required="true" hint="Submitted name with the comment" />
		<cfargument name="CommentAuthorEmail" type="string" required="true" hint="Submitted email address" />
		<cfargument name="CommentAuthorURL" type="string" required="true" hint="Commenter URL." />
		<cfargument name="CommentType" type="string" default="comment" hint="May be blank, comment, trackback, pingback, or a made up value like 'registration'" />
		<cfargument name="CommentContent" type="string" required="true" hint="The content that was submitted." />
		<cfargument name="Permalink" type="string" required="true" hint="The permanent location of the entry the comment was submitted to" />
		
		<cfset var retValue = false />
		<cfset var l = StructNew() />
		
		<!--- BH: Make sure this key is valid and has been verified--->
		<cfset verifySettings() />
		<cfset Arguments.RequestURL = getCommentURL() />
		
		<cfset retValue = sendAkismetRequest(ArgumentCollection=Arguments) />
		<cfreturn retValue />
	</cffunction>
	
	<cffunction name="submitSpam" returntype="void" hint="Submits a comment to Akismet which should have been marked as spam" output="false">
		<cfargument name="CommentAuthor" type="string" required="true" hint="Submitted name with the comment" />
		<cfargument name="CommentAuthorEmail" type="string" required="true" hint="Submitted email address" />
		<cfargument name="CommentAuthorURL" type="string" required="true" hint="Commenter URL." />
		<cfargument name="CommentType" type="string" default="comment" hint="May be blank, comment, trackback, pingback, or a made up value like 'registration'" />
		<cfargument name="CommentContent" type="string" required="true" hint="The content that was submitted." />
		<cfargument name="Permalink" type="string" required="true" hint="The permanent location of the entry the comment was submitted to" />

		<cfset verifySettings() />
		<cfset Arguments.RequestURL = getSpamURL() />
		
		<cfset sendAkismetRequest(ArgumentCollection=Arguments) />
	</cffunction>
	
	<cffunction name="submitHam" returntype="void" hint="Submits a comment to Akisment which was marked as spam but was actually legitimate" output="false">
		<cfargument name="CommentAuthor" type="string" required="true" hint="Submitted name with the comment" />
		<cfargument name="CommentAuthorEmail" type="string" required="true" hint="Submitted email address" />
		<cfargument name="CommentAuthorURL" type="string" required="true" hint="Commenter URL." />
		<cfargument name="CommentType" type="string" default="comment" hint="May be blank, comment, trackback, pingback, or a made up value like 'registration'" />
		<cfargument name="CommentContent" type="string" required="true" hint="The content that was submitted." />
		<cfargument name="Permalink" type="string" required="true" hint="The permanent location of the entry the comment was submitted to" />

		<cfset verifySettings() />
		<cfset Arguments.RequestURL = getHamURL() />
		
		<cfset sendAkismetRequest(ArgumentCollection=Arguments) />
	</cffunction>
	
	<cffunction name="verifySettings" returntype="void" hint="Makes sure the required settings are valid" output="false">
		<cfif NOT Len(Trim(getKey()))>
			<cfthrow message="CFAkismet: You have not defined an API Key.  Make sure you've called the setKey() method with a valid key.  You can get an Akismet key at http://wordpress.com/api-keys/">
		</cfif>
		
		<cfif NOT Len(Trim(getBlogURL()))>
			<cfthrow message="CFAkismet:  You have not defined your blog URL.  Make sure you've called the setBlogURL() method with your blog URL." />
		</cfif>
		
		<cfif NOT Len(Trim(getApplicationName()))>
			<cfthrow message="CFAkismet:  You have not set the application name and version calling Akismet.  Make sure you've called the setApplicationName() method with your app name and version, such as 'ThisApp/1.1.10'" />
		</cfif>
	</cffunction>
	
	<cffunction name="sendAkismetRequest" returntype="boolean" access="private" hint="Submits requests to Akismet" output="false">
		<cfargument name="CommentAuthor" type="string" required="true" hint="Submitted name with the comment" />
		<cfargument name="CommentAuthorEmail" type="string" required="true" hint="Submitted email address" />
		<cfargument name="CommentAuthorURL" type="string" default="" hint="Commenter URL." />
		<cfargument name="CommentType" type="string" default="comment" hint="May be blank, comment, trackback, pingback, or a made up value like 'registration'" />
		<cfargument name="CommentContent" type="string" required="true" hint="The content that was submitted." />
		<cfargument name="Permalink" type="string" required="true" hint="The permanent location of the entry the comment was submitted to" />
		<cfargument name="RequestURL" type="string" required="true" hint="The URL to call for this request" />

		<cfset var httpReturn = StructNew() />
		<cfset var retValue = false />
		<cfset var httpSuccess = true />
		<cfset var CFHTTP = StructNew() />

		<cftry>
			<cfhttp url="#Arguments.RequestURL#" timeout="#HTTPTimeout#" method="post">
				<cfhttpparam name="key" type="formfield" value="#getKey()#" />
				<cfhttpparam name="blog" type="formfield" value="#getBlogURL()#" />
				<cfhttpparam name="user_ip" type="formfield" value="#getUserIP()#" />
				<cfhttpparam name="user_agent" type="formfield" value="#getUserAgent()#" />
				<cfhttpparam name="referrer" type="formfield" value="#getReferrer()#" />
				<cfhttpparam name="permalink" type="formfield" value="#Arguments.Permalink#" />
				<cfhttpparam name="comment_type" type="formfield" value="#Arguments.CommentType#" />
				<cfhttpparam name="comment_author" type="formfield" value="#Arguments.CommentAuthor#" />
				<cfhttpparam name="comment_author_email" type="formfield" value="#Arguments.CommentAuthorEmail#" />
				<cfhttpparam name="comment_author_url" type="formfield" value="#Arguments.CommentAuthorURL#" />
				<cfhttpparam name="comment_content" type="formfield" value="#Arguments.CommentContent#" />
			</cfhttp>
			<cfset httpReturn = CFHTTP />
			<cfcatch type="any">
				<cfset httpSuccess = false />
				<cfthrow message="CFAkismet.sendAkismetRequest():  An error occured when trying to reach <cfoutput>#Arguments.RequestURL#</cfoutput>" />
			</cfcatch>
		</cftry>
		
		<cfif httpSuccess AND Trim(httpReturn.FileContent) EQ "true">
			<cfset retValue = true />
		</cfif>
		
		<cfreturn retValue />
	</cffunction>
	
	<cffunction name="sendKeyVerification" returntype="boolean" access="private" hint="Sends a key verification request to Akismet" output="false">
		<cfset var httpReturn = StructNew() />
		<cfset var retValue = false />
		<cfset var httpSuccess = true />
		<cfset var CFHTTP = StructNew() />
		
		<cftry>
			<cfhttp url="#getKeyURL()#" timeout="#HTTPTimeout#" method="post">
				<cfhttpparam name="key" type="formfield" value="#getKey()#" />
				<cfhttpparam name="blog" type="formfield" value="#getBlogURL()#" />
			</cfhttp>
			<cfset httpReturn = CFHTTP />
			<cfcatch type="any">
				<cfset httpSuccess = false />
				<cfthrow message="CFAkismet.sendKeyVerification():  An error occured when trying to reach <cfoutput>#getKeyURL#</cfoutput>" />
			</cfcatch>
		</cftry>
		
		<cfif httpSuccess AND Trim(httpReturn.FileContent) EQ "valid">
			<cfset retValue = true />
		</cfif>
		
		<cfreturn retValue />
	</cffunction>
	
</cfcomponent>