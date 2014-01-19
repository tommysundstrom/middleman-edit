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
$LOG = Logger.new(logpath, 'monthly')
$LOG.level = Logger::DEBUG
$LOG.info '==============================================================='
$LOG.info 'STARTING middleman-edit'


# Chrome version
# (If you are using Safari, uncomment that line)
#
# (Code for other browsers can be found here:
# https://gist.github.com/vitorgalvao/5392178#file-get_title_and_url-applescript )
#
script = "tell application \"Google Chrome\" to get URL of active tab of front window"
#script = "tell application \"Safari\" to return URL of front document"
url = %x{osascript -e '#{script}'}
$LOG.info "URL: #{url}"
TerminalNotifier.notify(url, :title => 'Middleman edit', :subtitle => "TEST")

# Strip \n
url.chomp!


# Get the page's html code
html = ''
open(url) do |f|                    # TODO Handle 404
  html = f.read
  TerminalNotifier.notify(url, :title => 'Middleman edit', :subtitle => "Unable to get page")
  $LOG.warn "Unable to get #{url}" if html.empty?
  raise "Unable to get #{url}" if html.empty?
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
  $LOG.warn "Found source meta for #{url}, but can not extract content" if source.empty?
  raise "Found source meta for #{url}, but can not extract content" if source.empty?
else
  source = result[1]
end

# Check that the source file exist
unless File.exist?(source)
  # Check if the site has been slimmed down for development, see https://github.com/tommysundstrom/middleman-slim-the-site
  #       (Checks parent folders for a directory named 'source'. This is NOT the same as the variable source)
  path = Pathname.new(source).parent
  source_found = false
  path.ascend do |ancestor|
    next unless ancestor.exist?
    if ancestor.basename == 'source'
      maybe_middleman = true
      if (ancestor + '_WARNING - This site is slimmed for development.lock').exist?
        # The site has been slimmed down by middleman-slim-the-site.
        # Looking for the file in the backup, and if found, moving it back into the site.
        backup_source = source.sub('/source/', '/source_unslimmed_copy/')
        if File.exist?(backup_source)
          # The file exist, but has been slimmed away. Moving it back.
          FileUtils.copy_entry(backup_source, source)
          source = backup_source
          source_found = true
          break
        end
      end
    end
  end
  unless source_found
    errmsg "Can't find file #{source}"
    TerminalNotifier.notify(source, :title => 'Middleman edit', :subtitle => "Unable to find the source")
    $LOG.warn errmsg
    raise errmsg
  end
end


# Open the source file (Uncomment the option that suits you best.)
TerminalNotifier.notify(source, :title => 'Middleman edit', :subtitle => "Opening source file")
$LOG.info "Opening #{source}"

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