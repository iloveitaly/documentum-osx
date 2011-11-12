require 'rubygems'

# for documentum
require 'FileUtils'
require 'nokogiri'
require 'json'

# for spider
require 'net/http'
require 'uri'
require 'open-uri'
require 'hpricot'

# http://www.skorks.com/2009/07/how-to-write-a-web-crawler-in-ruby/

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
  
  attr_accessor :output_dir
  
  def initialize
    @already_visited = {}
    @output_dir = nil
    @assets = {}
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
    begin
      return if @already_visited.size == page_limit
    
      url_object = open_url(url)
      return if url_object == nil
    
      parsed_url = parse_url(url_object)
      return if parsed_url == nil
    
      # pull assets off page onto disk, rewrite assets references
      find_assets_on_page(parsed_url, url)
    
      # save to disk
      save_url(url, parsed_url) if not @output_dir.nil?
    
      @already_visited[url] = true if @already_visited[url] == nil
      page_urls = find_urls_on_page(parsed_url, url)
      page_urls.each do |page_url|
        if urls_on_same_domain?(url, page_url) and @already_visited[page_url] == nil
          crawl_domain(page_url)
        end
      end
    rescue Exception => e
      puts "Error loading url #{url} with message #{e}"
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
  
  def flatten_url(url)
    # TODO: possible downcase here 
    
    # convert slashes to hypens
    convertedPath = URI.parse(url).path
    convertedPath.gsub!(/^\/|\/$/, '')
    
    # remove beginning / ending hyphens
    convertedPath.gsub!('/', '-')
    convertedPath
  end
  
  def save_url(url, page_content, html=true)
    convertedPath = flatten_url(url)

    if html
      convertedPath = "index" if convertedPath.empty?
      convertedPath += ".html"
    end
    
    Dir.mkdir(@output_dir) if not File.exists? @output_dir
    
    File.open(File.join(@output_dir, convertedPath), "w") { |file| file.puts page_content}
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
      new_url, anchor = x['href'].split('#')
      unless new_url == nil
        if relative?(new_url)
         new_url = make_absolute(current_url, new_url)
        end
        
        urls_list.push(new_url)
        
        begin
          # fix URL reference for local consumption
          x["href"] = flatten_url(new_url) + (anchor ? "#" + anchor : "")
        rescue Exception => e
          puts "Error flattening URL #{new_url}"
        end        
      end
    end
    
    return urls_list
  end
  
  # TODO: pull images as well
  def find_assets_on_page(parsed_url, current_url)
    # find CSS
    parsed_url.search('link[@rel="stylesheet"]').map do |link|
      begin
        flattened_name = flatten_url(link["href"])
      rescue Exception => e
        puts "Error converting URL #{current_url}, #{e}"
        next
      end
      
      download_url = link["href"]
      if not download_url.start_with? 'http'
        url_peices = URI.parse(current_url)
      
        if download_url.start_with? '//'
          download_url = url_peices.scheme + ":" + download_url
        else
          download_url = url_peices.scheme + '://' + File.join(url_peices.host, download_url)
        end
      end
      
      if not @assets[flattened_name]
        begin
          # TODO: doesn't handle query string correctly
          puts "Downloading: " + download_url
          save_url(download_url, open_url(download_url).read, false)
          @assets[flattened_name] = true
        rescue Exception => e
          puts "Error downloading #{e}"
        end
      end
      
      link["href"] = download_url
    end
    
    # find images
  end

  private :open_url, :update_url_if_redirected, :parse_url, :find_urls_on_page
end

class DocumentationHierarchy
  def self.hierarchy_hints=(hints)
    @@hierarchy_hints = hints
  end
  
  attr_accessor :children
  attr_accessor :name
  attr_accessor :parent
  attr_accessor :element
  attr_accessor :relative_root
  attr_accessor :path
  attr_reader   :distance
  
  def initialize(options = {})
    @children = options[:children] || []
    @parent = options[:parent] || nil
    @element = options[:element] || nil
    @name = options[:name] || nil
    
    # determine distance to the top
    @distance = 0
    @path = []
    
    unless @parent.nil?
      current = self
    
      while true
        @path << current
        current = current.parent
        break if current.nil?
        
        @distance += 1
      end
    end
    
    @path.reverse!
    
    if @parent.nil?
      @relative_root = @element
    else
      @relative_root = @element.parent
      
      # check for relative group hinting
      if @@hierarchy_hints[@distance - 1].class == Array
        # then we have hints!
        case @@hierarchy_hints[@distance - 1].last
        when -1
          # this indicates the root node
          @relative_root = @path.first.element
        else
          # TODO: fine grained parent hinting
        end
      end
    end
  end
end

class DocumentationIndexHelper  
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
    
    # create the docs dir
    Dir.mkdir @docs_path if not File.exists? @docs_path and File.exists? @plugin_directory
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
    # if the docs dir is empty, remove it
    Dir.rmdir(@docs_path) if Dir[File.join @docs_path, '*'].empty?
    
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
  
  def crawl(domain)
    @spider = Spider.new
    @spider.output_dir = @docs_path
    @spider.crawl_domain(domain, 200)
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
  
  def get_hierarchy_reference(relative_hierarchy)
    return @structure if relative_hierarchy.distance == 0
    
    hierarchy_reference = @structure
    
    for p in relative_hierarchy.path
      next if p.distance == 0
      
      hierarchy_reference[p.name]["children"] = Hash.new unless hierarchy_reference[p.name].has_key? "children"
      hierarchy_reference = hierarchy_reference[p.name]["children"]
    end
    
    return hierarchy_reference
  end
  
  def generate_structure(*heiarchy)
    Dir.chdir(@docs_path)
    
    DocumentationHierarchy.hierarchy_hints = heiarchy
    @structure = heiarchicalElements = Hash.new
    
    # sensible defaults, but allow the dev to supply a specific file list
    if @file_list.empty?
      @file_list = Dir.glob("**/*.html").reject {|fn| File.directory?(fn) }
    end
    
    @file_list.each do |helpFile|
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
      element_stack = [DocumentationHierarchy.new(:element => helpDoc, :parent => nil)]
      new_element_stack = []
      previous_element_stack = []
      
      # move through the heiarchy for this page
      heiarchy.each_index do |index|
        
        # find all the elements corresponding to this depth level
        element_stack.each do |relative_hierarchy|
          currentHeiarchyReference = get_hierarchy_reference(relative_hierarchy)
          before_count = new_element_stack.length
          current_selector = heiarchy[index].class == Array ? heiarchy[index].first : heiarchy[index]
          
          puts "Relative Hierarchy: #{relative_hierarchy.name}: #{current_selector}"
          
          relative_hierarchy.relative_root.css(current_selector).each do |helpElement|
            if @process_name.class == Symbol
              helpElementName = self.send(@process_name, helpElement.content, index)
            elsif @process_name.class == Proc
              helpElementName = @process_name.call(helpElement.content, index, helpDoc, absoluteFilePath, helpElement)
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
              "path" => absoluteFilePath,
              "title" => helpElementName,
              "window_title" => windowTitle.downcase == helpElementName.downcase ? windowTitle : "%s – %s" % [windowTitle, helpElementName],
              "anchor" => anchor,
              "children" => {}
            }
          
            puts "Adding with Title #{helpElementName}"
            currentHeiarchyReference[helpElementName] = helpReference
            
            # TODO: add children
            new_element_stack << DocumentationHierarchy.new(:name => helpElementName, :element => helpElement, :parent => relative_hierarchy)
          
            # for the first heiarchy level there really only be one header, first level is meant to be the title
            # TODO: this should be a bit more flexible
            break if index == 0
          end
          
          # if we didn't find any for this level, add the current level of hierarchy so we can keep digging further
          new_element_stack << relative_hierarchy if before_count == new_element_stack.length
        end      
        
        # reset the element stack
        if new_element_stack.length > 0
          previous_element_stack << element_stack
          element_stack = new_element_stack
          new_element_stack = []
        else
          # element_stack = previous_element_stack.pop
          # new_element_stack = []
        end
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
