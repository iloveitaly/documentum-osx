#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
ih.content_holder_selector = "#description"
ih.rename_uncompressed_docs
ih.fix_asset_references
ih.anchor_locator = proc do |element, index, document|
  ""
  # if index == 0
  #   ""
  # else
  #   element.parent.parent.css("a[name*=method]").first["name"]
  # end
end
ih.generate_structure "h1.class, h1.module", "div.method-heading span.method-name"
# structure = ih.structure
# structure["Errors"] = {"children" => {}, "title" => "Error"}
# structure.each do |key, value|
#   # in ruby core errors are stored on the root, remove them and throw them into an errors section
#   if /Error$/ =~ key
#     structure["Errors"]["children"][key] = value
#     structure.delete(key)
#   end
# end
ih.write_structure