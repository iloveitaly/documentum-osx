#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

# TODO: Handle readmes & anchors

ih = DocumentationIndexHelper.new
ih.content_holder_selector = "#content"
ih.rename_uncompressed_docs
ih.fix_asset_references
ih.process_name = proc do |name, level|
  if name.include? "Class" or name.include? "Module"
    name.strip.gsub(/[Mm]odule[\s\n]+|[Cc]lass[\s\n]+/, "").match(/^[^ ]+/)[0]
  else
    name.strip
  end
end
ih.unimportant_content_selectors = "h1,h2,h3,h4,h5,div.sectiontitle,ul"
ih.generate_structure "h1", ".method .title"
ih.structure.each do |index,value|
  if (index.count "::") > 1
    ih.insert_tree_reference index.split("::"), value
    ih.structure.delete index
  else
    puts "Only once: #{index}"
  end
end
# ih.anchor_locator = proc do |element, index, document|
#   if index == 0
#     ""
#   else
#     element.parent.parent.css("a[name*=method]").first["name"]
#   end
# end
# ih.anchor_strip_prefix = "method-[ic]-"
ih.write_structure