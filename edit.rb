#
#
# For this to work, there must be a meta tag with the location of the source file
# in the page. Add this line inside <head> (haml version):
#
# %meta{:content => "#{current_page.source_file}", :name => "source"}
#
#
  # TODO RÄCKER RADEN OVAN? FINNS DET VERKLIGEN ALLTID EN SOURCE_FILE? I O F S FICK JAG INGA PROTESTER SOM JAG SÅG!!!!!
  #NÄR JAG BYGGDE. BÄTTRE MED HELPER? ELLER SKA JAG UTGÅ FRÅN ATT DEN ALLTID FINNS NU, MEN ATT DET
  #EV. KAN VARA SÅ ATT DEN IBLAND ÄR TOM?

require 'logger'
require 'fileutils'
require 'pathname'
require 'open-uri'

# Setup logging
logpath = File.expand_path('~/Library/Logs/Middleman/Edit/edit.log')
FileUtils.mkdir_p(File.dirname(logpath))
$LOG = Logger.new(logpath, 'daily')
$LOG.level = Logger::DEBUG
$LOG.info '==============================================================='
$LOG.info 'STARTING middleman-edit'

# Chrome version
# (Code for other browsers can be found here:
# https://gist.github.com/vitorgalvao/5392178#file-get_title_and_url-applescript )
script = "tell application \"Google Chrome\" to get URL of active tab of first window"
url = %x{osascript -e '#{script}'}
$LOG.info "Trying to edit #{url}, from Chrome"

# Strip \n
url.chomp!

# Get the page's html code
html = ''
open(url) do |f|
  html = f.read
  raise "Unable to download #{url}" if html.empty?
end


# Find the source meta tag
#    Get the meta tag
result = html.match( /^\s*(<meta.*name\s*=\s*['"]source['"].*>)$/ )
if result.nil?
  errmsg = "No reference to a Middleman source file in page #{url} "
  $LOG.warn errmsg
  raise errmsg
else
  meta_source_tag = result[1]
end

result = meta_source_tag.match( /content\s*=\s*['"](.*?)['"]/ )
if result.nil?
  raise "Found source meta for #{url}, can not extract content" if source.empty?
else
  source = result[1]
end

# If you want the source file revealed in Finder, uncomment this
=begin
script = "tell application \"Finder\" to reveal (POSIX file \"#{source}\")"
`osascript -e '#{script}'`
script = "tell application \"Finder\" to activate"
`osascript -e '#{script}'`
=end

# Open the source file with TextMate
%x{mate #{source}}


