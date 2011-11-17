#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
# ih.content_holder_selector = "#description"
ih.rename_uncompressed_docs
Dir.chdir(ih.docs_path)
ih.file_list = Dir.glob("**/*.html").reject {|fn| File.directory?(fn) or fn.start_with?("genindex-") or fn == "search.html" or fn == "download.html" }
# ih.file_list = ["library/stdtypes.html", "library/base64.html"]
# puts ih.file_list
# Process.exit
# ih.fix_asset_references
ih.process_name = proc do |name, level, *other|
  name = name.strip.sub("¶", "")
  
  case level
  when 0, 1
    literals = other.last.css(".literal")
    literals.length > 0 ? literals.first.content.strip : name.sub(/^[0-9.]+ /, '')
  else
    literals = other.last.css('.descname')
    literals.length > 0 ? literals.first.content.strip : name
  end
end
ih.generate_structure [".related:first-child > ul li:nth-child(7) a", -1], [".related:first-child > ul li:nth-child(8) a", -1], "h1", "h2", "h3", ".class dt, .data dt, .function dt, .method dt"
ih.write_structure