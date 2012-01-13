ColdBreadCrumbs
=========

ColdBreadCrumbs aims to provide a dynamic set of breadcrumbs for a given session
without the need for database interaction or any real knowledge of how pages
are related to each other.

Overview
----------

ColdBreadCrumbs keeps track of the actual path of pages you travel through on a site
and builds that breadcrumb trail for you dynamically as you go.  You just specify what the
root page(s) of your site are and whenever those are visited the breadcrumb trail will be reset.
Each link in the trail will include all url and form arguments that were used to get there but,
never fear, you can tell ColdBreadCrumbs to ignore certain arguments.

Why?
----------

I needed an easy way to show a breadcrumb trail but I didn't want to have to manage a document or database
of page relationships.  Plus, ColdFusion made this really easy to do.

Usage
----------

I'm not going to lie.  This thing is pretty ugly.  I wrote it a long time ago and have only made a minimal effort to improve
it over time.  While it does work the usage isn't that obvious - anyway there are two main steps.


1 Configure breadcrumb.cfm 
        
* Jump down to line 240, that's where the configuration starts.  You will notice a few parts depend on a viewstate - that's because I use it with coldspring and never got around to updating this to be more generic.  One thing you probably want to do is define all the page titles associated with your page keys somewhere.  For instance in my sites all pages are loaded like so:  index.cfm?page=<somepage>  where <somepage> is the page key.  So if I have a page listing all the users on the site it might be at index.cfm?page=userlist  Thus, instead of hardcoding the title for that page on the view for that page I'll define it in a structure of pages like so:       
        <cfset pages = structNew() />  
        <cfset pages.userList = "All Users" />

Then breadcrumb.cfm can fetch the page caption from that structure if you prefer (or however you want to reference that structures data within your application.

* ignorePages is a comma delimited list of page keys that you want to ignore when displaying the breadcrumb trail

* ignorePageArgs is a comma delimeted list of url and form arguments that you never want to have included in a breadcrumb elements hyperlink.

* Homepage definitions are a little tricky.  There is a structure called homePageStruct.  For each home page you want to define you should add a new structure element to the homepagestruct.  So if you have just one homepage you can call do this:
        
        <cfset homePageStruct= structNew()/>
        <cfset homePageStruct.home = structNew() />
        <cfset homePageStruct.home.text = "Site Home" />
        <cfset homePageStruct.home.page = "Home" />
        <cfset homePageStruct.home.args = "" />
        <cfset homePageStruct.home.link = "index.cfm" />

You don't really need to worry about the args key beyond making sure it is defined; however, you may end up wanting more than one "homepage" and when that happens you'll want to create another element in your homePageStruct like so:

	<cfset homePageStruct.altHome = structNew()>
	<cfset homePageStruct.altHome.Text = "Alt Site Home">
	<cfset homePageStruct.altHome.Page = "altHome">
	<cfset homePageStruct.altHome.args = "?page=altHome">
	<cfset homePageStruct.altHome.link = "index.cfm">

the key "altHome" can be anything you want it to be. Thus if you have a sales and marketing home page and a it home page you could call one key salesHome and one itHome.

2. Include the breadcrumb.cfm where you want the breadcrumb trail to appear:
        <cfinclude template="util/breadcrumb.cfm">


Apologies
----------
I am sorry this code is in such a shabby state.  It could seriously benefit from some refactoring (complete rewriting?) but it does work and may help you a little.  If you like it and want to improve upon it branch away and I'll try to figure out how to incorporate your changes as I learn more about Git.  If there are any mistakes in this readme I apologize as well - I wrote it on the last day of 2009 and I wrote breadcrumb.cfm in 2005

Caveats
----------
This readme probably isn't complete - please read the "descriptive" text in breadcrumb.cfm for further information and pay attention to any comments you find there while you're at it.  I'm pretty sure I've ported this to a CFC; I just have to find it.