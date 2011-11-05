#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

# man page numbers: http://www.december.com/unix/ref/mansec.html

ih = DocumentationIndexHelper.new

man_paths = ["/usr/share/man", "/usr/local/man", "/usr/share/man", "/opt/local/share/man"]
man_file_glob = "man[0-9,a-z,A-Z]/*"
man_exclude_list = ["/man3/"]
man_file_list = []

# possibly organize the man files into 1,2,3,4... and fork the process, wait on all the pids, then generate structure
# the man --> HTML takes a LONG time

count = 100
man_paths.reject{|man_dir| not File.exists? man_dir }.each do |man_dir|
  Dir[File.join man_dir, man_file_glob].each do |man_file|
    next if man_exclude_list.collect{|exclude_dir| man_file.include? exclude_dir}.include? true
    
    puts "Original: #{man_file}"
    man_save_name = File.basename(man_file.sub(/\.gz$/, '')) + ".html"
    
    next if man_file_list.include? man_save_name
    
    if File.extname(man_file) == ".gz"
      man_html = %x[gunzip -cd "#{man_file}" | groff -t -man -Thtml 2>/dev/null]
    else
      man_html = %x[groff -t -man -Thtml "#{man_file}" 2>/dev/null]
    end
    
    puts "Saving #{man_save_name}"
    
    # link up the "SEE ALSO" references to other pages
    man_html.gsub!(/(?:<b>)?([a-z_0-9]+)(?:<\/b>)?\(([1-9])\)/).each do |match|
      "<a href=\"" + File.join("file://", ih.docs_path, "#{$1}.#{$2}.html") + "\">#{$1}(#{$2})</a>"
    end
    
    File.open(File.join(ih.docs_path, man_save_name), "w") {|file| file.puts man_html}
    
    man_file_list << man_save_name
    # 
    # count += 1
    # break if count > 20
  end
end

ih.process_name = proc do |name, *args|
  name.strip.downcase
end
ih.generate_structure "h1"
ih.write_structure