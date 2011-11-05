#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

# https://github.com/yimmu/Man-to-html/blob/master/man-2-html.py
# 
# def man_to_html(manpage)  
#   if manpage[-2:] == "gz"
#     data = os.popen("gunzip -cd " + manpage + "| groff -t -man -Thtml 2>/dev/null", "r")
#   else:
#     data = os.popen("groff -t -man -Thtml " + manpage + " 2>/dev/null", "r")
#     
#   b = manpage.split("/")[-2]
#   c = b+"/"+manpage.split("/")[-1]
#   
#   if not os.access(outdir, os.F_OK):
#     os.mkdir(outdir)
#     
#   if not os.access(outdir+"/"+b, os.F_OK):
#     os.mkdir(outdir+"/"+b)
#     
#   f = open(outdir+"/"+c+".html", "w")
#   for lines in data:
#     f.write(lines)    
#   f.close

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
    
    File.open(File.join(ih.docs_path, man_save_name), "w") {|file| file.puts man_html}
    
    man_file_list << man_file
  end
end
# 
# man_paths = glob.glob(path + "man[0-9,a-z,A-Z]/*")
# man_paths.sort()
# 
# for i in range(len(man_paths)):
#   if os.access(man_paths[i], os.F_OK):
#     manpage = os.listdir(man_paths[i])
#     manpage.sort()
#     for y in range(len(manpage)):
#      man_to_html(man_paths[i]+"/"+manpage[y])
