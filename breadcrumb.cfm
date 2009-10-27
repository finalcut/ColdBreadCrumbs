<cfsilent>
	<!--- dsp.breadcrumb.cfm - Copyright (c) 2005 SBCS, Inc. 
	
		as you can see this was written a long time ago - you're welcome to update to a more functional approach if you want.
	--->

	<!---
		Description:
			I maintain and build a dynamic breadcrumb trail (showing each page a user has visited).

			NOTE: All URL and FORM variables should be moved into the Attribute scope before calling this file.
			there are plenty of existing examples of code available to accomplish this. By convention we typically
			call said method in our application.cfm file.

			
		Parameters:
			NONE; just must be included in the context of your site where the URL and FORM scope are still
			available.  These variables will be in the attributes scope by now - but this rule is important or
			else you might lose many important attributes, unless you always passon attributesCollection to each
			level of your page/circuit.
			
		Usage:
			<cfinclude template="dsp.breadcrumb.cfm">

		Revision History:
			2/25/2005	wmrawlin	this header block finally added after a complete rewrite.

	--->


<cffunction name="buildURlInfo" access="public" returntype="struct" output="false">
	<!---
		Description:
			I build a structure that contains all the information needed to build a hypertext link to the current page.
		Parameters:
			@param	pageVariable	if you use a "switch" type mechanism and everything runs through index.cfm - then what
									is the name of the variable you switch on: ie: index.cfm?page=thisPage or index.cfm?fuseaction=go
									the pagevariables would be page and fuseaction respectively.

			@param	pageCaption		the name of the current page.  Basically the title or what ever it is you want displayed in
									the breadcrumb trail for this page.

			@param	ignoreAttrs		a comma delmited list of attribute keys to ignore.  As attribues is a structure, you just provide
									a list of keys to not include in the breadcrumb URL.
			
			@param	returnVariable	the variable you want populated.  This tag returns a structure of the form:
									struct
										struct.link - the base url with the first "pageVariable" if one exists
										struct.text - the text you want displayed.  Basically just a copy of pageCaption
										struct.args - a string of argumnents to append to the link.

										so if you wanted to display this link you would:

										<cfoutput><a href="#struct.link#">#struct.link##struct.args#</a></cfoutput>

									you don't have to figure out if a ? or a & goes between url and arguments as it 
									is built into the struct.args value that is returned

									the link and the argument are separated for a reason as it provides the most flexibility
									for any calling file.

		Usage:

			<cfset urlInfo = "#attributes#","page","Home Page", "comma,delmited,list,of,attributes,to,ignore">


		Revision History:
			2/25/2005	wmrawlin	this header block finally added after a complete rewrite.
			10/27/2009  wmrwalin	turned this into a funciton (was a cfmodule) and i have not tested it as a function at all.

	--->

	<cfargument name="attributeCollection" type="struct" default="#StructNew()#">
	<cfargument name="pageCaption"	type="string"	default="">
	<cfargument name="pageVariable"	type="string"	default="">
	<cfargument name="ignoreAttrs"	type="string"	default="">


	<!--- define our return structure --->
	<cfset var urlInfo = structNew()>
	<cfset urlInfo.link	= ListGetAT(cgi.script_name,ListLen(cgi.script_name,"/"),"/")>
	<cfset urlInfo.text	= arguments.pageCaption>
	<cfset urlInfo["#arguments.pageVariable#"] = arguments.page />
	<cfset urlInfo.args = "">

	<!--- make sure the current pageVariable is ignored --->
	<cfset arguments.ignoreAttrs = ListAppend(arguments.ignoreAttrs,attributes.pageVariable)>	

	<!--- make sure some special attributes are ignored --->
	<cfset arguments.ignoreAttrs = ListAppend(arguments.ignoreAttrs,"ignoreAttrs,pageCaption,attributeCollection,pageVariable,returnVariable")>
	<!--- 
		try to figure out what arguments were passed in via
		form and url or arguments
	--->
	<cfloop List="#StructKeyList(arguments.attributeCollection)#" Index="thisKey">
		<cfif isSimpleValue(arguments.attributeCollection[thisKey])>
			<cfif NOT ListFindNoCase(arguments.attributeCollection.ignoreAttrs,thisKey) AND Len(arguments.attributeCollection[thisKey]) AND thisKey NEQ "BREADCRUMB">
				<cfset urlInfo.args = ListAppend(urlInfo.args,"#thisKey#=#URLENCODEDFORMAT(attributes[thisKey])#","&")>
			</cfif>
		</cfif>
	</cfloop>

	<!--- prepend with an & or an ? for the first element --->
	<cfif len(urlInfo.args) and len(arguments.pageVariable)>
		<cfset urlInfo.args		= "?#arguments.pageVariable#=" & attributes.page & "&" & urlInfo.args>
	<cfelseif len(urlInfo.args)>
		<cfset urlInfo.args = "?#urlInfo.args#">
	<cfelseif len(arguments.pageVariable)>
		<cfset urlInfo.args		= "?#arguments.pageVariable#=" & attributes.page />
	</cfif>



	<cfreturn urlInfo>

</cffunction>

<!--- UTILITY FUNCTIONS --->
<cfscript>
	<!--- these are normally in a separate file and I don't have the time to figure out which functions I'm using so I'm dropping a bunch of utility functions in here
			the only one I think that is used is "ArrayLeft"  hopefully you'll find some value in the additional functions
	--->
	


	function ListDeleteLeft(list, numElements) {
		var delimiter=",";
		var array = ArrayNew(1);
		if (Arraylen(arguments) gt 2) {
			delimiter=arguments[3];
		}

		array = ListToArray(list,delimiter);
		array = arrayDeleteLeft(array,numElements);
		if(isArray(array))
			list = ArrayToList(array,delimiter);
		else
			list = array;

		return list;
	}

	function ArrayDeleteLeft(array,numElements){
		var i=0;
		var t = true;
		if (numElements gt ArrayLen(array)) return "";
		for (i=1; i lte numElements; i=i+1) {
			t=ArrayDeleteAt(array, 1);
		}
		return array;
	}

	function ListLeft(list, numElements){
		var delimiter=",";
		var array = ArrayNew(1);
		if (Arraylen(arguments) gt 2) {
			delimiter=arguments[3];
		}

		array = ListToArray(list,delimiter);
		array = arrayLeft(array,numElements);

		if(isArray(array))
			list = ArrayToList(array,delimiter);
		else
			list = array;

		return list;
	}


	function ArrayLeft(array,numElements){
	  var tArray= ArrayNew(1);
	  if (numElements gte arrayLen(array)){
		return array;
	  }
	  for (i=1; i LTE numElements; i=i+1){
		tArray[i] = array[i];
	  }

	  return tArray;
	}

	function listToArrayOfLists(list){
		var size = 50;
		var delimiter=",";
		var outArray = arrayNew(1);
		var i = 1;


		if (Arraylen(arguments) gt 1) {
			size=arguments[2];
		}
		if (Arraylen(arguments) gt 2) {
			delimiter=arguments[3];
		}


		while(listLen(list)){
			outArray[i] = listLeft(list,size,delimiter);
			list = listDeleteLeft(list,size,delimiter);
			i = i + 1;
		}

		return outArray;

	}
	function listClean(list){
		var delimiter = ",";
		var outList = "";
		var tArray = ArrayNew(1);
		var i = 1;
		if (Arraylen(arguments) gt 2) {
			delimiter=arguments[3];
		}


		tArray = ListtoArray(list,delimiter);


		for(i = 1; i LTE ArrayLen(tArray); i=i+1){
			if(val(tArray[i]) GT 0){
				outList = ListAppend(outList,VAL(tArray[i]),delimiter);
			}
		}

		return outList;
	}
	function listDropEmpty(list){
		var newList = "";
		var i = 1;
		var tArray = ListToArray(list);
		for(i=1; i LTE arrayLen(tArray); i=i+1){
			newList = listAppend(newList,tArray[i]);
		}
		return newList;

	}
</cfscript>


	<cfset pageCaption = viewState.getValue("pageData").caption />
	<cfset mybreadcrumb = viewState.getValue("breadcrumb")>
	<cfset curPage = viewState.getValue("page")>>

	<!--- list of pages we don't want to show up in the breadcrumb trail --->
	<cfset ignorePages = "login,Undefined Page Caption">

	<cfset breadCrumb = ArrayNew(1)>
	<!--- this is the title of your sites root page.  we need to know this, you can define multiple "roots" for yoursite if you want... --->
	<cfset homePageStruct = structNew() />

	<cfset homePageStruct.home = structNew()>
	<cfset homePageStruct.home.Text = "Site Home">
	<cfset homePageStruct.home.Page = "Home">
	<cfset homePageStruct.home.args = "">
	<cfset homePageStruct.home.link = "index.cfm">

	<!--- 
		example of an alternate root definition; you can call it whatever 
		you want, in this example it is "altHome" whatever that is it must 
		match the .page value for the pages structure.  Then anytime the site
		loads the home or the alt-home page it will "clear out" the breadcrumb trail
		back to the "home" level



	<cfset homePageStruct.altHome = structNew()>
	<cfset homePageStruct.altHome.Text = "Alt Site Home">
	<cfset homePageStruct.altHome.Page = "altHome">
	<cfset homePageStruct.altHome.args = "?page=altHome">
	<cfset homePageStruct.altHome.link = "index.cfm">

	--->


	<!--- we store the breadcrumb structure as a WDDX packet in the client.breadcrumb variable --->
	<cfif NOT isWddx(mybreadcrumb)>
		<cfwddx action="cfml2wddx" input="#breadcrumb#" output="mybreadcrumb">
	</cfif>

	<!--- at this point we need to grab the existing breadcrumb info into a local variable --->
	<cfwddx action="wddx2cfml" input="#mybreadcrumb#" output="breadcrumb">


	
	<!--- if we are at the root page of the site, reset the trail --->
	<cfif ListFindNoCase(structKeyList(homePageStruct),curPage)>
		<cfset breadCrumb = ArrayNew(1)>
		<cfset urlInfo = homePageStruct["#curPage#"] />

	<cfelse>

		<cfset ts = viewState.getAll() >

		<!--- i pass "password" in as an ignoreAttr to be on the safe side for security concerns --->
		<!--- i pass "block" in as an ignoreAttr so we don't end up locking someone out of the site accidently --->
		<cfset urlInfo = buildURlInfo(ts, pageCaption, "page", "fieldnames,username,submitform,password,block,init,self,myself,style,homeurl,eventvalue,pagekey,responsetype,allowpageedit,ecrsummarystatus,facilitytypename,clientid,clientcode" />
		
	</cfif>



	<!--- now determine if this linkText exists in the trail - if so we need
	to trim the trail down to this point --->
	<cfset thisPageEntryIndex = 0>

	<cfloop from="1" to="#ArrayLen(breadCrumb)#" index="bi">
		<cfif breadCrumb[bi].text EQ urlInfo.text>
			<cfset thisPageEntryIndex = bi>
			<cfbreak>
		</cfif>
	</cfloop>

	<!--- 
		  this does exist in the list already, so start trimming - even though
		  I could have trimmed in the last loop, this seems cleaner and much
		  easier to read
	--->
	<cfif thisPageEntryIndex>
		<cfset breadCrumb = ArrayLeft(breadCrumb,thisPageEntryIndex)>
	<cfelseif NOT ListFindNoCase(Trim(ignorePages),Trim(urlinfo.text))>

		<!--- new breadcrumb entry, add it to the array --->
		<cfset ArrayAppend(breadCrumb,urlInfo)>
	</cfif>

		<!--- save our breadcrumb back to the client variable as a WDDX packet --->
		
		<cfwddx action="cfml2wddx" input="#breadcrumb#" output="mybreadcrumb">
		<cfset viewState.setValue("breadcrumb",mybreadcrumb) />

</cfsilent>


<!--- display the breadcrumb --->
<cfoutput>

<!--- 
	display as an ordered list - because that is what it is in reality 
	I use some styles to hide the list "look" and make it run horizontally
	across the page
--->
<ol id="breadcrumb">
	<cfset lastCrumb = ArrayLen(breadCrumb)>
	<cfloop from="1" to="#lastCrumb#" index="bi">
		<cfif bi EQ lastCrumb AND breadCrumb[bi].page EQ urlinfo.page>
			<li><span>#breadCrumb[bi].text#</span></li>
		<cfelse>
			<cfset thisLink="#breadCrumb[bi].link##breadCrumb[bi].args#">
			<li><a href="#xmlFormat(thisLink)#" title="#xmlFormat(breadCrumb[bi].text)#">#xmlFormat(breadCrumb[bi].text)#</a>&gt;</li>
		</cfif>
	</cfloop>
</ol>
<br class="clear" />
<h2 id="pagecaption">
	#pageCaption#
</h2>
</cfoutput>
