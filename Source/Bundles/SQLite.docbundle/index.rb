#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
# ih.content_holder_selector = "#description"
ih.rename_uncompressed_docs
# ih.fix_asset_references
# ih.process_name = proc do |name, level, *opts|
#   conv = Iconv.new("UTF-8//IGNORE","ASCII")
#   name = conv.iconv(name)
#   name.strip.sub(/Chapter\s?[0-9]{1,2}\./, "")
# end
ih.generate_structure "h1[id]", "h2"
ih.write_structure