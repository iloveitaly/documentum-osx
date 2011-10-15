#!/usr/bin/env ruby

$plugin_directory = Dir.pwd

class DocIndexHelper
  require 'rubygems'
  require 'FileUtils'
  require 'nokogiri'
  require 'json'
  
  attr_accessor :anchor_locator
  attr_accessor :structure_path
  
  def initialize
    @strip_javascript = true
    @docs_dir = "docs"
    @anchor_locator = nil
    
    @docs_path = File.join($plugin_directory, @docs_dir)
    @structure_path = File.join($plugin_directory, "structure.json")
    @process_element_name = :process_element_name
  end
  
  def process_element_name(name, level)
    name = name.strip
    rootName = name[/^[a-zA-Z_:]+/]
    
    if rootName.nil?
      puts "No match for #{name}"
    end
    
    rootName
  end
  
  # when the doc download is uncompressed it still has the old name... we want to rename it to /docs
  def rename_uncompressed_docs
    docs = Dir['ruby_?_?_?_core']
    if not docs.empty?
      FileUtils.mv(File.join(Dir.pwd, docs), File.join(Dir.pwd, "docs"))
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
      absoluteFilePath = File.join($plugin_directory, @docs_dir, f)
      
      if File.extname(f) == ".html"
          doc = Nokogiri::HTML(File.open(absoluteFilePath))
          
          # remove javascript if desired
          doc.xpath("//script").remove if @strip_javascript
          
          # relink css
          doc.xpath("//link").each do |link|
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
          helpElementName = self.send(@process_element_name, helpElement.content, index)
          
          # skip empty entries
          next unless not (helpElementName.nil? || helpElementName.empty?)
          
          # find associated anchor
          anchor = @anchor_locator.call(helpElement, index, helpDoc) if not @anchor_locator.nil?
          
          currentHeiarchyReference[helpElementName] = {:path => absoluteFilePath, :title => helpElementName, :anchor => anchor}

          lastHeiarchyKey = helpElementName
        end
        
        # search for matching elements
      end      
    end
    
    # save the structure json
    File.open(@structure_path, "w") { |file| file.puts JSON.pretty_generate(heiarchicalElements) }
  end
end

ih = DocIndexHelper.new
# ih.rename_uncompressed_docs
# ih.fix_asset_references
ih.anchor_locator = proc do |element, index, document|
  return "" if index == 0
  return element.parent.parent.css("a[name*=method]").first["name"]
end
ih.generate_structure "h1.class, h1.module", "div.method-heading span.method-callseq"