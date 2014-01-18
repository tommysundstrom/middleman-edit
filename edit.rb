

# There are some trouble.
# When paths are manipulated before rendering, it can be hard to figure out the origin of the page (for
# example, blog paths where year/month/day or a slug has been added to the path).
#   It can also be hard to identify dynamic pages.

#require 'uri'
require 'logger'
require 'fileutils'
require 'pathname'

# Setup logging
logpath = File.expand_path('~/Library/Logs/Middleman/Edit/edit.log')
FileUtils.mkdir_p(File.dirname(logpath))
$LOG = Logger.new(logpath, 'daily')
$LOG.level = Logger::DEBUG
$LOG.info '==============================================================='
$LOG.info 'STARTING middleman-edit'

# Chrome version
# url = `osascript -e 'tell application \"Google Chrome\" to get URL of active tab of first window'`
# url = `#{"osascript -e 'tell application \"Google Chrome\" to get URL of active tab of first window'"}`
script = "tell application \"Google Chrome\" to get URL of active tab of first window"
url = `osascript -e '#{script}'`
$LOG.info "Trying to edit #{url}, from Chrome"

# Strip \n
url.chomp!

# Strip http
if url.start_with?('http://')
  url = url[7..-1]
elsif url.start_with?('https://')
  url = url[8..-1]
else
  raise "Unknown protocol in #{url}"
end

# Strip query
query_position = url.index('?')
url = url[0..(query_position - 1)] unless query_position.nil?


# Check if domain is known, and what site it belongs to

sites = [
    {
        :identifiers => ['localhost:4567', 'anvandbart.se', 'www.anvandbart.se'],
        :middlemansite => '~/Sites/Middleman/anvandbart.se'
    }
]

local_path = nil
source = nil
catch (:file_found)  do
  until sites.empty?
    site = sites.shift
    until site[:identifiers].empty?
      identifier = site[:identifiers].shift
      if (url).start_with?(identifier)
        source = Pathname.new( File.expand_path(site[:middlemansite]) ) + 'source'
        local_path = Pathname.new(url[identifier.length+1..-1])
        throw :file_found             #, source + local_path  # (Will be the value of the cache block)
      end
    end
  end
  # Nothing found
  errmsg = "#{url} is not a known Middleman site"
  $LOG.warn errmsg
  raise errmsg
end
# source and local_path should be set now

# Massage local_path
# (For example, many sites needs the local_path to start with 'blog'.)
chain = local_path.each_filename.to_a

#   This is probably quite specific to my site, so remove or modify for your site
case
  when chain.count == 0 # Root
    $LOG.info 'Root'
    # do nothing
  when chain.count > 1, ['ab', 'artdirected', 'iot', '2014'].index(chain.first)    # Subsection
    $LOG.info 'Subsection'
    # do nothing
  # (Note that the chain now must contain exactly one item)
  else
    case chain.first
      when 'index.html',  # The sites index page
        'toc',            # Other pages that lives in the source directory
        'toc.html',
        'sitemap.xml'
        $LOG.info 'Item in source folder'
        # do nothing
      else
        # Seams that the page is part of the blog
        local_path = Pathname.new('blogsource') + local_path
        $LOG.info 'Blog item'
    end
end

# Show in finder (man får själv leta inuti foldern)
script = "tell application \"Finder\" to reveal (POSIX file \"#{(source + local_path).parent.to_s}\")"
`osascript -e '#{script}'`
script = "tell application \"Finder\" to activate"
`osascript -e '#{script}'`

# Find the file, by testing different suffixes   # Add suffixes and combinations that you use
suffixes = [
    '.slim',
    '.erb',
    '.rhtml',
    '.erubis',
    '.less',
    '.builder',
    '.liquid',
    '.markdown',
    '.mkd',
    '.md',
    '.textile',
    '.rdoc',
    '.radius',
    '.mab',
    '.nokogiri',
    '.coffee',
    '.wiki',
    '.creole',
    '.mediawiki',
    '.mw',
    '.yajl',
    '.styl',
    '.markdown.erb',
    '.mkd.erb',
    '.md.erb',
    '.textile.erb',
]


# Stub
almost = source + local_path   # This is almost the complete file path, but something is missing
                               # Note: almost is a pathname

# Check if it's a directory
if (almost.to_s)[-1..-1] == '/'    # If the last char is a slash
  # A directory
  almost = almost + 'index.html'   # this is the file we're looking for
end

# Now it's for certain a file. Start searching for it.

file_pathname = catch(:f) do

  # Is it a xml file?
  if almost.extname == '.xml'
    throw :f, almost if almost.exist?   # Ok as it is

    throw :f, Pathname.new(almost.to_s + '.builder') if File.exist?(almost.to_s + '.builder')   # This is the only
    # version of xml extension that I'm aware of.

    TROR NÄSTAN DET ÄR ENKLARE GÖRA DETTA SOM FUNKTION ÄN ATT HÅLLA PÅ MED CACHE
    RETURER KAN VARA
    pathname pekar på filen
    :notfound => använd parent istället
    return :notfound    # => Öppnar parent
  end

  # Check if it's something else then a .html file
  unless almost.extname == '.html'
    # If not a html document, the path is probably ok as it is  # TODO builder
  end

  # Dags att hitta html-dokumentet

  # Taktik:

  ## Sök efter filen (https://discussions.apple.com/thread/2428025). Förhoppningsvis kan man begränsa (eller filtrera)
  # fram bara den aktuella directoriet, och använda ”börjar med”. Om man gör det bara i foldern, borde man kunna
  # hantera multippla träffar genom att markera flera. Fast, bttre, vid multipla, ge ett felmeddelande.



  throw :found, almost u File.exist?   # If not a html document, the path is probably ok as it is  # TODO builder
end


# Check if it's something else then a .html file


unless almost.extname == '.html'
  throw



else
  # A file
  if almost.extname == '.html'
    # A document
  end
end

#



if File.directory?(almost)
  # append the file
  almost += '/index.html'  #TODO Kolla slashar

end

#



filepath = catch(:found) do

  unless almost.end_with? '.html'
    throw :found, almost if File.exist?
  end
end

almost + '/index.html'


# Add .html and start to test suffixes






# NGT SVÅRARE

# Testa olika ändelser tills jag hittar filen (finns en LITEN risk för fel här, men den tror jag är minimal)

# Show in finder (eller open with..., ev beroende på ändelse)