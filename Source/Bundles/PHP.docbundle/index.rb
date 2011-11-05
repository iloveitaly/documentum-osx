#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../documentum'

ih = DocumentationIndexHelper.new

# PHP documentation doesn't seem to have empty pages unlike ruby
# ih.content_holder_selector = nil

ih.rename_uncompressed_docs

# the PHP docs don't contain any asset references
# ih.fix_asset_references

# however, the PHP docs have ALOT of pages that are mostly annoying
# we are going to parse the heirachy in the index.html page and include 

Dir.glob(File.join ih.docs_path, "class.*").each do |classFile|
  classDoc = Nokogiri::HTML(File.open classFile)
  
  # refname is used for three pages: com, dir, dotnet
  classNameMatches = classDoc.css("h1.title, h1.refname")
  
  if classNameMatches.length > 0
    className = classNameMatches[0].content
  else
    puts "Bad h1 reference #{classFile}"
  end
  
  # PHP formats its class names as "The ___ class"
  matches = /The ([^ ]+)/.match(className)
  
  if matches and matches.length > 0
    isolatedClassName = matches[1]
  else
    puts "Bad name match #{className}"
    isolatedClassName = className
  end
  
  isolatedClassName.strip!
  
  # puts isolatedClassName
  
  # get tree reference to the class
  treePath = ['Class', isolatedClassName]
  treeReference = ih.insert_tree_reference(treePath, {
    :path => classFile,
    :title => isolatedClassName
  })
  
  # extract all method calls
  classDoc.css("a.methodname").each do |classMethodName|
    nameText = classMethodName.content
    
    if nameText.include? "::"
      nameText = nameText.split("::")[1]
    else
      # puts isolatedClassName + "::" + nameText
    end
    
    nameText.strip!
    
    # puts classMethodName["href"]
    ih.insert_tree_reference(treePath + [nameText], {
      :path => File.join(ih.docs_path, classMethodName["href"]),
      :title => nameText
    })
  end
end

Dir.glob(File.join ih.docs_path, "function.*").each do |functionFile|
  classDoc = Nokogiri::HTML(File.open functionFile)
  
  functionNameMatches = classDoc.css('h1.refname')
  
  if functionNameMatches.length > 0
    functionName = functionNameMatches[0].content
  else
    puts "Bad function reference #{functionFile}"
    functionName = classDoc.css("h2.title")[0].content
  end
  
  functionName.strip!
  
  treePath = ['Functions', functionName]
  ih.insert_tree_reference(treePath, {
    :path => functionFile,
    :title => functionName
  })
end

ih.write_structure
