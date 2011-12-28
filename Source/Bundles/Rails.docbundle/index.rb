#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

# TODO: Handle readmes & anchors

ih = DocumentationIndexHelper.new
ih.content_holder_selector = "#content"
ih.rename_uncompressed_docs
ih.fix_asset_references
ih.process_name = proc do |name, *args|
  if name.include? "Class" or name.include? "Module"
    name.strip.gsub(/[Mm]odule[\s\n]+|[Cc]lass[\s\n]+/, "").match(/^[^ ]+/)[0]
  elsif File.basename(args.last).include? "README"
    begin
      args[1].css('.banner').remove
      "Readme::" + args[1].css("h1").first.content.strip
    rescue
      "Readme::" + args[1].css("h2").first.content.strip
    end
  else
    name.strip
  end
end
ih.unimportant_content_selectors = "h1,h2,h3,h4,h5,div.sectiontitle,ul"

# for testing
# ih.file_list = ['classes/ActionView/Helpers/FormBuilder.html']

# the -1 instructs the next level of selectors to start from the top (in this case the next level selectors are not located under the h1)
ih.generate_structure ["h1", -1], ".method .title b"
ih.structure.each do |index,value|
  if (index.count "::") > 1
    ih.insert_tree_reference index.split("::"), value
    ih.structure.delete index
  else
    puts "Only once: #{index}"
  end
end
ih.write_structure