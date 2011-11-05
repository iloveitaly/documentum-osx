# http://www.skorks.com/2009/07/how-to-write-a-web-crawler-in-ruby/

require 'net/http'
require 'uri'
require 'open-uri'
require 'rubygems'
require 'hpricot'

module UrlUtils
  def relative?(url)
    if url.match(/^http/)
      return false
    end
    return true
  end

  def make_absolute(potential_base, relative_url)
    absolute_url = nil;
    if relative_url.match(/^\//)
      absolute_url = create_absolute_url_from_base(potential_base, relative_url)
    else
      absolute_url = create_absolute_url_from_context(potential_base, relative_url)
    end
    return absolute_url
  end

  def urls_on_same_domain?(url1, url2)
    return get_domain(url1) == get_domain(url2)
  end

  def get_domain(url)
    return remove_extra_paths(url)
  end

  def create_absolute_url_from_base(potential_base, relative_url)
    naked_base = remove_extra_paths(potential_base)
    return naked_base + relative_url
  end

  def remove_extra_paths(potential_base)
    index_to_start_slash_search = potential_base.index('://')+3
    index_of_first_relevant_slash = potential_base.index('/', index_to_start_slash_search)
    if index_of_first_relevant_slash != nil
      return potential_base[0, index_of_first_relevant_slash]
    end
    return potential_base
  end

  def create_absolute_url_from_context(potential_base, relative_url)
    absolute_url = nil;
    if potential_base.match(/\/$/)
      absolute_url = potential_base+relative_url
    else
      last_index_of_slash = potential_base.rindex('/')
      if potential_base[last_index_of_slash-2, 2] == ':/'
        absolute_url = potential_base+'/'+relative_url
      else
        last_index_of_dot = potential_base.rindex('.')
        if last_index_of_dot < last_index_of_slash
          absolute_url = potential_base+'/'+relative_url
        else
          absolute_url = potential_base[0, last_index_of_slash+1] + relative_url
        end
      end
    end
    return absolute_url
  end

  private :create_absolute_url_from_base, :remove_extra_paths, :create_absolute_url_from_context
end

class Spider
  include UrlUtils
  
  def initialize
    @already_visited = {}
  end

  def crawl_web(urls, depth=2, page_limit = 100)
    depth.times do
      next_urls = []
      urls.each do |url|
        url_object = open_url(url)
        next if url_object == nil
        url = update_url_if_redirected(url, url_object)
        parsed_url = parse_url(url_object)
        next if parsed_url == nil
        @already_visited[url]=true if @already_visited[url] == nil
        return if @already_visited.size == page_limit
        next_urls += (find_urls_on_page(parsed_url, url)-@already_visited.keys)
        next_urls.uniq!
      end
      urls = next_urls
    end
  end

  def crawl_domain(url, page_limit = 100)
    return if @already_visited.size == page_limit
    url_object = open_url(url)
    return if url_object == nil
    parsed_url = parse_url(url_object)
    return if parsed_url == nil
    @already_visited[url]=true if @already_visited[url] == nil
    page_urls = find_urls_on_page(parsed_url, url)
    page_urls.each do |page_url|
      if urls_on_same_domain?(url, page_url) and @already_visited[page_url] == nil
        crawl_domain(page_url)
      end
    end
  end

  def open_url(url)
    url_object = nil
    begin
      url_object = open(url)
    rescue
      puts "Unable to open url: " + url
    end
    return url_object
  end

  def update_url_if_redirected(url, url_object)
    if url != url_object.base_uri.to_s
      return url_object.base_uri.to_s
    end
    return url
  end

  def parse_url(url_object)
    doc = nil
    begin
      doc = Hpricot(url_object)
    rescue
      puts 'Could not parse url: ' + url_object.base_uri.to_s
    end
    puts 'Crawling url ' + url_object.base_uri.to_s
    return doc
  end

  def find_urls_on_page(parsed_url, current_url)
    urls_list = []
    parsed_url.search('a[@href]').map do |x|
      new_url = x['href'].split('#')[0]
      unless new_url == nil
        if relative?(new_url)
         new_url = make_absolute(current_url, new_url)
        end
        urls_list.push(new_url)
      end
    end
    return urls_list
  end

  private :open_url, :update_url_if_redirected, :parse_url, :find_urls_on_page
end

class DocumentationIndexHelper
  require 'rubygems'
  require 'FileUtils'
  require 'nokogiri'
  require 'json'
  
  attr_accessor :anchor_locator
  attr_accessor :anchor_strip_prefix
  attr_accessor :content_holder_selector
  attr_accessor :structure_path
  attr_accessor :structure
  attr_accessor :process_name
  attr_accessor :unimportant_content_selectors
  attr_accessor :file_list
  
  attr_accessor :docs_dir
  attr_accessor :docs_path
  
  def initialize
    # set defaults
    @strip_javascript = true
    @anchor_strip_prefix = ""
    @anchor_locator = nil
    @process_name = :process_element_name
    @file_list = []   # define a list of files to process
    @structure = Hash.new
    
    # these determine if the page is empty or not
    @content_holder_selector = nil
    @unimportant_content_selectors = "h1,h2,h3,h4,h5"
    
    @docs_dir = "docs"
    @plugin_directory = Dir.pwd
    @docs_path = File.join(@plugin_directory, @docs_dir)
    @structure_path = File.join(@plugin_directory, "structure.json")
  end
  
  # this processed the raw HTML content inside of 'identifer' tag
  # and strips it down to something that should be displayed in the app
  def process_element_name(name, level)
    name = name.strip
    rootName = name[/^[a-zA-Z_:]+/]
    
    if rootName.nil?
      puts "No match for #{name}"
    end
    
    rootName
  end
  
  # path is an ordered array, ex: ['errors', 'array', 'IndexError']
  def insert_tree_reference(path, insertion)
    currentReference = @structure
    
    # use index and not the value, end of path detection with values causes problems with duplicate items in the path
    path.each_index do |index|
      levelName = path[index]
      
      # puts "Path Level " + index
      currentReference = currentReference["children"] if currentReference != @structure

      if not currentReference.has_key? levelName
        currentReference[levelName] = {"children" => {}, "title" => levelName}
      elsif not currentReference[levelName].has_key? "children"
          currentReference[levelName]["children"] = {}
      end

      if path.length == index + 1
        currentReference[levelName] = insertion
      end
      
      currentReference = currentReference[levelName]
    end
    
    currentReference
  end
  
  private :process_element_name
  
  # when the doc download is uncompressed it still has the old name... we want to rename it to /docs
  # this assumes we are in the original PWD
  def rename_uncompressed_docs
    docs = Dir[File.basename(@plugin_directory) + '*']
    
    if docs.empty?
      directories = Dir["*"].reject {|fn| not File.directory?(fn) }
      
      if directories.length == 1
        docs = directories[0]
      else
        docs = ""
      end
    end
    
    if docs.empty? or (docs.class == String and File.basename(docs) == @docs_dir)
      puts "Error finding docs directory or already exists"
    else
      FileUtils.mv(File.join(Dir.pwd, docs), File.join(Dir.pwd, @docs_dir))
    end
  end
  
  # often downloadable documentation references CSS / JS incorrectly
  def fix_asset_references
    asset_converter = Hash.new
    
    Dir.chdir(@docs_dir)
    file_list = Dir.glob("**/*.*").reject {|fn| File.directory?(fn) }
    
    # generate the converter list
    file_list.each do |f|
      case File.extname(f)
      when ".js"
      when ".css"
        asset_converter[File.basename(f)] = f
      end
    end
    
    file_list.each do |f|
      absoluteFilePath = File.join(@plugin_directory, @docs_dir, f)
      
      if File.extname(f) == ".html"
          doc = Nokogiri::HTML(File.open(absoluteFilePath))
          
          # remove javascript if desired
          doc.xpath("//script").remove if @strip_javascript
          
          # relink css
          doc.xpath("//link").each do |link|
            originalLinkPath = File.basename(link["href"])
            
            next if File.extname(originalLinkPath) != ".css"
            next if not asset_converter.has_key? File.basename(originalLinkPath)
            
            # convert the link paths
            link["href"] = ("../" * (f.count "/")) + asset_converter[File.basename(link["href"])]
          end
          
          # relink images
          
          # write the converted file
          File.open(absoluteFilePath, "w") { |file| file.puts doc }
      end
    end
  end
  
  def generate_structure(*heiarchy)
    Dir.chdir(@docs_path)
    
    heiarchicalElements = Hash.new
    currentHeiarchyReference = nil
    lastHeiarchyKey = nil
    
    # sensible defaults, but all the dev to supply a specific file list
    if @fileList.empty?
      @fileList = Dir.glob("**/*.html").reject {|fn| File.directory?(fn) }
    end
    
    @fileList.each do |helpFile|
      absoluteFilePath = File.join(@docs_path, helpFile)
      helpDoc = Nokogiri::HTML(File.open(absoluteFilePath))
      
      # the window title is used for a peice of the heirarchy in the app's title
      windowTitle = helpDoc.xpath("//title")[0].content
      
      # check if we are dealing with a empty page
      # define content_holder_selector & unimportant_content_selectors
      if not @content_holder_selector.nil? and not @unimportant_content_selectors.nil?
        isEmptyFile = false
        
        helpDoc.css(@content_holder_selector).each do |match|
          # work with a copy of the doc since we are removing elements
          tempDocSubset = match.dup()
          tempDocSubset.css(@unimportant_content_selectors).remove
          if tempDocSubset.content.to_s.strip.empty?
            # puts "Length #{tempDocSubset.content.to_s.strip.length}"
            # puts tempDocSubset.content.to_s.strip
            isEmptyFile = true
          end
        end
        
        if isEmptyFile
          puts "Skipping empty file #{absoluteFilePath}"
          next
        end
      end
      
      # default anchor wiring script: put all anchors in a list for future reference
      if @anchor_locator.nil?
        # there has got to be a better way to handle this...
        anchor_list = []
        helpDoc.css("a[name]").each do |a|
          if @anchor_strip_prefix.empty?
            anchor_list << a["name"]
          else
            # sometimes docs have anchor prefixes that can be stripped out for easy matching
            anchor_list << a["name"].gsub(/#{@anchor_strip_prefix}/, '')
          end
        end
      end
      
      # reset heirachical variables
      currentHeiarchyReference = heiarchicalElements
      lastHeiarchyKey = nil
      
      # move through the heiarchy for this page
      heiarchy.each_index do |index|
        # find current heiarchy position & set empty hashs
        # note that this only works for 2 levels deep currently
        # to work with more levels there would have to be a 'find parent match' method
        
        currentHeiarchyReference = heiarchicalElements
        heiarchyDepth = index
        while heiarchyDepth > 0
            break unless not lastHeiarchyKey.nil?
            currentHeiarchyReference = currentHeiarchyReference[lastHeiarchyKey]["children"] = Hash.new
            heiarchyDepth -= 1
        end
        
        # find all the elements corresponding to this depth level
        helpDoc.css(heiarchy[index]).each do |helpElement|
          if @process_name.class == Symbol
            helpElementName = self.send(@process_name, helpElement.content, index)
          elsif @process_name.class == Proc
            helpElementName = @process_name.call(helpElement.content, index, helpDoc, absoluteFilePath)
          end
          
          # skip empty entries
          next if helpElementName.nil? || helpElementName.empty?
          
          # find associated anchor
          # TODO: this is completely broken
          anchor = ""
          if @anchor_locator.nil?
            # grab all the anchors 
            anchorText = helpElementName.gsub(/[^a-zA-Z]/, '')
            anchorMatches = anchor_list.select do |i|
              i == anchorText
            end
            
            if anchorMatches.length == 0
              # puts "::" + helpElementName
              # anchorText = helpElementName.gsub(/[^a-zA-Z]/, '')
              # i =~ /^#{Regexp.escape(anchorText)}|#{Regexp.escape(anchorText)}$/
              
            end
            
            if anchorMatches.length > 1
              # puts "---------"
              # puts helpElementName.gsub(/[^a-zA-Z]/, '')
              # puts anchorMatches
            end
          else
            anchor = @anchor_locator.call(helpElement, index, helpDoc)
          end
          
          helpReference = {
            :path => absoluteFilePath,
            :title => helpElementName,
            :window_title => "%s – %s" % [windowTitle, helpElementName],
            :anchor => anchor
          }
          
          currentHeiarchyReference[helpElementName] = helpReference

          lastHeiarchyKey = helpElementName
          
          # for the first heiarchy level there really only be one header, first level is meant to be the title
          # TODO: this should be a bit more flexible
          break if index == 0
        end
        
        # search for matching elements
      end      
    end
    
    @structure = heiarchicalElements
  end
  
  def write_structure
    # TODO: take another look at the sorting issue here
    @structure.keys.sort_by {|s| s.to_s }.map{|key| [key, @structure[key]] }
    File.open(@structure_path, "w") { |file| file.puts JSON.pretty_generate(@structure) }
  end
end
