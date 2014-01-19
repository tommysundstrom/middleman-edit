middleman-edit
==============

(Mac only) Open the Middleman source file of the page currently in the web browser, thus making it easy to edit the text.

Works both with the development server and on the final site.

Use Alfred (http://www.alfredapp.com/), or any other of numerous options to run this script from a hotkey. Or
 call it from the command line.


## Add meta-tag to source

For this script to work, there must be a meta tag with the location of the source file
 of the page. Add this line inside <head> (haml version):

`%meta{:content => "#{current_page.source_file}", :name => "source"}`


## Dependencies

* Uses AppleScript, so works only on Mac
* (Terminal Notifier)[http://rubygems.org/gems/terminal-notifier]