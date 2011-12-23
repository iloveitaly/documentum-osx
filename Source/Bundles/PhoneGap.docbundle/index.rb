#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
# ih.content_holder_selector = "#description"
ih.rename_uncompressed_docs

# this downloads the entire phone gap library
# the docs dir is hidden in the folder structure, lets pull it out
# phone_gap_folder/Documentation/en/edge

# lastest_documentation = Dir.glob(File.join ih.docs_path, "Documentation/en/*").sort[-2]
# temp_doc_path = ih.docs_path + "_new"
# FileUtils.move lastest_documentation, temp_doc_path
# FileUtils.remove ih.docs_path
# FileUtils.move temp_doc_path, ih.docs_path
# 
# # ih.fix_asset_references
# # ih.process_name = proc do |name, level, *opts|
# #   conv = Iconv.new("UTF-8//IGNORE","ASCII")
# #   name = conv.iconv(name)
# #   name.strip.sub(/Chapter\s?[0-9]{1,2}\./, "")
# # end
# ih.generate_structure "#index li"
# ih.write_structure
