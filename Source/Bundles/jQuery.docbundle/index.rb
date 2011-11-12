#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
ih.crawl "http://docs.jquery.com/"
# ih.generate_structure "#menu > h4", "div.menu-item a"
# ih.write_structure