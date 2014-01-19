#
#
# For this to work, there must be a meta tag with the location of the source file
# in the page. Add this line inside <head> (haml version):
#
# %meta{:content => "#{current_page.source_file}", :name => "source"}


require 'logger'
require 'fileutils'
require 'pathname'
require 'open-uri'
require 'terminal-notifier'  # http://rubygems.org/gems/terminal-notifier

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
  TerminalNotifier.notify(url, :title => 'Middleman edit', :subtitle => "Unable to get page")
  raise "Unable to download #{url}" if html.empty?
end


# Find the source meta tag
#    Get the meta tag
result = html.match( /^\s*(<meta.*name\s*=\s*['"]source['"].*>)$/ )
if result.nil?
  errmsg = "No reference to a Middleman source file in page #{url} "
  TerminalNotifier.notify(url, :title => 'Middleman edit', :subtitle => "Page contains no source file reference to a Middleman source file")
  $LOG.warn errmsg
  raise errmsg
else
  meta_source_tag = result[1]
end

result = meta_source_tag.match( /content\s*=\s*['"](.*?)['"]/ )
if result.nil?
  TerminalNotifier.notify(url, :title => 'Middleman edit', :subtitle => "Unable to extract content from source tag")
  raise "Found source meta for #{url}, can not extract content" if source.empty?
else
  source = result[1]
end



# Open the source file (Uncomment the option that suits you best.)

%x{open #{source}}      # Default application

#%x{mate #{source}}     # TextMate

#%x{mvim #{source}}     # MacVim

#%x{bbedit #{source}}   # BBEdit

#%x{open -a TheApplication #{source}}     # Replace AnApplication with the application you want to use

#%x{open -a MarkdownLife #{source}}       # MarkdownLife

# %x{open -a RubyMine #{source}}    # RubyMine (for more advanced options,
          # see https://www.jetbrains.com/ruby/webhelp/working-with-rubymine-features-from-command-line.html )

# Default application, using Finder to open it
=begin
script = "tell application \"Finder\" to open (POSIX file \"#{source}\")"
%x{osascript -e '#{script}'}
=end

# Show the file in Finder
=begin
script = "tell application \"Finder\" to reveal (POSIX file \"#{source}\")"
%x{osascript -e '#{script}'}
script = "tell application \"Finder\" to activate"
%x{osascript -e '#{script}'}
=end