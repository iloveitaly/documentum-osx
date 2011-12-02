#!/usr/bin/env ruby

# other options:
#   http://www.w3.org/TR/1998/REC-CSS2-19980512/css2.zip

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
# ih.crawl "http://css-infos.net/", :restrict => true
ih.generate_structure "h1 > code"
ih.write_structure
