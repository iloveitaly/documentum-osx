#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new

sp = Spider.new
sp.output_dir = ih.docs_path
sp.crawl_domain("https://developer.mozilla.org/en/JavaScript/Reference", 100)