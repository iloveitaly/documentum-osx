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
  
  def initialize
    # set defaults
    @strip_javascript = true
    @docs_dir = "docs"
    @anchor_strip_prefix = ""
    @anchor_locator = nil
    @content_holder_selector = nil
    @process_name = :process_element_name
    @unimportant_content_selectors = "h1,h2,h3,h4,h5"
    
    @plugin_directory = Dir.pwd
    @docs_path = File.join(@plugin_directory, @docs_dir)
    @structure_path = File.join(@plugin_directory, "structure.json")
  end
  
  def process_element_name(name, level)
    name = name.strip
    rootName = name[/^[a-zA-Z_:]+/]
    
    if rootName.nil?
      puts "No match for #{name}"
    end
    
    rootName
  end
  
  def insert_tree_reference(path, insertion)
    currentReference = @structure
    
    path.each do |index|
      # puts "Path Level " + index
      currentReference = currentReference["children"] if currentReference != @structure
      
      if not currentReference.has_key? index
        currentReference[index] = {"children" => {}, "title" => index}
      elsif not currentReference[index].has_key? "children"
          currentReference[index]["children"] = {}
      end

      if path.last == index
        currentReference[index] = insertion
      end
      
      currentReference = currentReference[index]
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
    
    fileList = Dir.glob("**/*.html").reject {|fn| File.directory?(fn) }.each do |helpFile|
      absoluteFilePath = File.join(@docs_path, helpFile)
      helpDoc = Nokogiri::HTML(File.open(absoluteFilePath))
      
      # check if we are dealing with a empty 
      if not @content_holder_selector.nil?
        isEmptyFile = false
        
        helpDoc.css(@content_holder_selector).each do |match|
          tempDocSubset = match.dup()
          tempDocSubset.css(@unimportant_content_selectors).remove
          if tempDocSubset.content.to_s.strip.empty?
            puts "Length #{tempDocSubset.content.to_s.strip.length}"
            # puts tempDocSubset.content.to_s.strip
            isEmptyFile = true
          end
        end
        
        if isEmptyFile
          puts "Skipping empty file #{absoluteFilePath}"
          next
        end
      end
      
      # reset heirachical variables
      currentHeiarchyReference = heiarchicalElements
      lastHeiarchyKey = nil
      
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
          anchor = ""
          if @anchor_locator.nil?
            # TODO: this needs to be fixed
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
          
          helpReference = {:path => absoluteFilePath, :title => helpElementName, :anchor => anchor}
          currentHeiarchyReference[helpElementName] = helpReference

          lastHeiarchyKey = helpElementName
          
          # for the first heiarchy level there really only be one header, first level is meant to be the title
          break if index == 0
        end
        
        # search for matching elements
      end      
    end
    
    @structure = heiarchicalElements
  end
  
  def write_structure
    @structure.keys.sort_by {|s| s.to_s }.map{|key| [key, @structure[key]] }
    File.open(@structure_path, "w") { |file| file.puts JSON.pretty_generate(@structure) }
  end
end
