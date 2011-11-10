#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new
ih.crawl "http://docs.kohanaphp.com/contents"