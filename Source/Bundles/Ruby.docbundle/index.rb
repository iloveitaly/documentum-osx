#!/usr/bin/env ruby

$plugin_directory = Dir.pwd

class DocIndexHelper
  require 'rubygems'
  require 'FileUtils'
  require 'nokogiri'
  
  def rename_uncompressed_docs
    docs = Dir['ruby_?_?_?_core']
    if not docs.empty?
      FileUtils.mv(File.join(Dir.pwd, docs), File.join(Dir.pwd, "docs"))
    end
  end

  def fix_asset_references
    asset_converter = Hash.new
    
    Dir.glob("docs/**/*.*").reject {|fn| File.directory?(fn) }.each do |f|
      absoluteFilePath = File.join($plugin_directory, f)
      
      case File.extname(f)
      # when ".html"
      #   doc = Nokogiri::HTML(File.open(absoluteFilePath))
      #   doc.xpath("//script").remove
      #   doc.xpath("//link").each do |link|
      #     puts link
      #   end
      when ".css"
        puts f
      end
    end
  end

  def strip_javascript
    # http://stackoverflow.com/questions/1980845/removing-the-script-elements-of-an-html
  end  
end

puts "hello"

ih = DocIndexHelper.new
ih.rename_uncompressed_docs
ih.fix_asset_references