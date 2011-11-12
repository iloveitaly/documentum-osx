#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
ih.crawl "http://mootools.net/docs/core/", :restrict => true
ih.generate_structure "#menu > h4", "div.menu-item a"
ih.write_structure
