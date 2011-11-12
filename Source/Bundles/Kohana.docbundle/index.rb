#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
ih.crawl "http://docs.kohanaphp.com/contents"
ih.generate_structure "h1", "h3"
ih.write_structure