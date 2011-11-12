#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
ih.crawl "https://developer.mozilla.org/en/JavaScript/Reference", :restrict => "https://developer.mozilla.org/en/"
ih.generate_structure ["h1", -1], "h2", "a"
ih.write_structure
