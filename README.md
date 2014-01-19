middleman-edit
==============

(Mac only) Opens the Middleman source file of the page currently in the web browser, making it quick to edit the text.

Currently takes the page from Chrome and opens the source with TextMate, but this is easy to change by commenting
in/out lines in the code.

Works both with the development server and on the final site.

Use [Alfred](http://www.alfredapp.com/), or any other of numerous options to run this script from a hotkey. Or
 call it from the command line.


## Add meta-tag to source

For this script to work, there must be a meta tag with the location of the source file
 of the page. Add this line inside <head> (haml version):

`%meta{:content => "#{current_page.source_file}", :name => "source"}`


## Dependencies

* Uses AppleScript, so works only on Mac
* [Terminal Notifier](http://rubygems.org/gems/terminal-notifier)

Note. The Run Script action i Alfred is using the system Ruby installation, so to install Terminal Notifier
 you need to do
 ```
 rvm use system
 sudo gem install terminal-notifier
 rvm use default
 ```

