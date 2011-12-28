#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
# ih.crawl "http://docs.jquery.com/"
# ih.crawl "http://api.jquery.com/", :exclude_urls => ["http://api.jquery.com/browser", "http://api.jquery.com/jsonp/"]
ih.file_list = ['index.html']
ih.name_type = DocumentationIndexHelper::NAME_NORMAL_TYPE
ih.generate_structure "#method-list .title-link"
ih.write_structure