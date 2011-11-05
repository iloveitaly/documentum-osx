#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new

man_paths = ["/usr/share/man", "/usr/local/man", "/usr/share/man", "/opt/local/share/man"]
man_file_glob = "man[0-9,a-z,A-Z]/*"
man_file_list = []

man_paths.reject{|man_dir| not File.exists? man_dir }.each do |man_dir|
  Dir[File.join man_dir, man_file_glob].each do |man_file|
    man_save_name = File.basename(man_file.sub(/\.gz$/, ''))
    
    next if man_file_list.include? man_save_name
    
    if File.extname(man_file) == ".gz"
      man_html = %x[gunzip -cd "#{man_file}" | groff -t -man -Thtml 2>/dev/null]
    else
      man_html = %x[groff -t -man -Thtml "#{man_file}" 2>/dev/null]
    end
    
    puts "Saving #{man_save_name}"
    
    File.open(File.join(ih.docs_path, man_save_name), "w") {|file| file.puts man_html}
    
    man_file_list << man_file
  end
end
