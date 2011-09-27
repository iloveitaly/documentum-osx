#!/usr/bin/python

import os, re, sys, user, shutil

#print os.getcwd()
#print sys.argv
#print sys.path

# RegEx: http://www.amk.ca/python/howto/regex/

if len(sys.argv) > 1:
	sys.path.append(sys.argv[1])
else:
	sys.path.append("/Users/Mike/Library/Application Support/PyHelp/pymodules")

import sqlite3
import xml.etree.cElementTree as xmlTree
from BeautifulSoup import BeautifulSoup

def walktree(top = ".", depthfirst = True):
	import os, stat, types
	names = os.listdir(top)
	if not depthfirst:
		yield top, names
	for name in names:
		try:
			st = os.lstat(os.path.join(top, name))
		except os.error:
			continue
		if stat.S_ISDIR(st.st_mode):
			for (newtop, children) in walktree (os.path.join(top, name), depthfirst):
				yield newtop, children
	if depthfirst:
		yield top, names

# looks through the file
def createIndexForFile(file):
	global globalIndex, helpDir
	
	titleFinder = re.compile(r"<title>(.*?)</title>", re.MULTILINE|re.DOTALL)
	
	# when class="method" it is the "definition"
	# when class="function" a function is being referenced
		
	methodFinder = re.compile(r"(method|function|module)\".*?>(.*?)</tt")
	tagRemover = re.compile('<([^!>]([^>]|\n)*)>|\\(.*\\)') # also removes anything between ()

	fd = open(file)
	contents = fd.read()
	fd.close()

	# search for the page title
	# there are many functions/methods with the same name, we need the page title to differentiate them
	pageName = titleFinder.search(contents).group(1).strip()
	
	# search for keywords, methods, and functions in the contents of a file
	matches = methodFinder.findall(contents)
	if len(matches) > 0:
		for method in matches:
			# method[0] = type, method[1] = name
			# (keyword, type, page_name, file)
			
			keyword = tagRemover.sub('', method[1])
			if not globalIndex.has_key(keyword):
				globalIndex[keyword] = (keyword, method[0], pageName, file)
			elif file.find(keyword) != -1:
				# then we should do "priority assignments"
				# if the file has the keyword in it that is a good sign
				# if the keyword is contained within a header tag, that is better
				
				if globalIndex[keyword][2].find(keyword) == -1:
					# then the keyword is found in the new file, but not in the current file
					# the new file wins
					globalIndex[keyword] = (keyword, method[0], pageName, file)
				else:
					titleFinder = re.compile(r"<h1>.*? "+keyword+" .*?</h1>", re.MULTILINE|re.DOTALL)
					if len(titleFinder.findall(contents)) > 0:
						globalIndex[keyword] = (keyword, method[0], pageName, file)					

def createTreeForDirectory(dir):
	global xmlIndex, helpDir
	titleFinder = re.compile(r"<title>(.*?)</title>")
	dupIndexPath = os.path.join(dir, os.path.basename(os.path.realpath(dir)) + ".html")
	indexPath = os.path.join(dir, "index.html")
	depth = 1
	
	# dupIndexPath seems to always exist
	indexPath = dupIndexPath
	
	if os.path.exists(indexPath):
		fd = open(indexPath)
		contents = fd.read()
		fd.close()
		
		# Add the new section
		newSection = xmlTree.SubElement(xmlIndex, "section", {'title':titleFinder.search(contents).group(1), 'path':indexPath})
		
		# all html seem to have their "outline" in an <ul class="ChildLinks">
		# try to grab that list, and then hand it off to be recursively searched
		linkList = re.compile(r"<ul class=\"ChildLinks\">.*</ul>", re.M | re.S).search(contents).group(0)
		linkTree = BeautifulSoup(linkList)
		recursiveLinkSearch(linkTree.contents[0], newSection, depth, dir)

def recursiveLinkSearch(node, indexNode, depth, relPath):
	itemFinder = re.compile(r"<a href=\"(.*?)\">(.*?)</a", re.M | re.S)
	titleCleaner = re.compile('<([^!>]([^>])*)>|\n| (?= )') # cleans up the linkName by removing tags, newlines, and double spaces
	
	for link in node.findAll("li", {}, False):
		linkItem = itemFinder.search(link.prettify())
		linkPath = relPath + '/' + linkItem.group(1).strip()
		linkName = titleCleaner.sub('', linkItem.group(2)).strip()
		
		# look for anchor links
		# if we find one seperate the anchor and URL
		anchorIndex = linkPath.find("#")
		if anchorIndex != -1:
			strippedLinkPath = linkPath[0:anchorIndex]
			anchor = linkPath[anchorIndex + 1:]
			#print strippedLinkPath + ' : ' + anchor
			newSection = xmlTree.SubElement(indexNode, "level"+str(depth), {'title':linkName, 'path':strippedLinkPath, 'anchor':anchor})
		else:
			newSection = xmlTree.SubElement(indexNode, "level"+str(depth), {'title':linkName, 'path':linkPath})
		#print linkPath, linkName
		
		depth += 1
		for list in link.findAll("ul", {}, False):
			recursiveLinkSearch(list, newSection, depth, relPath)
		depth -= 1

def main():
	# Declare global variables
	global supportDir, helpDir, globalIndex, xmlIndex
	
	# the first line is for non-production
	supportDir = user.home + '/Library/Application Support/PyHelp/python/'
	# supportDir = os.path.realpath(os.getcwd()) + "/"
	
	# find the python help files
	helpDir = filter(re.compile("python", re.IGNORECASE).search, os.listdir(supportDir))
	xmlIndex = xmlTree.XML("<index/>")
	globalIndex = {}
	
	# make sure the dir containing the help files is named "python docs"
	if helpDir[0] != "pythondocs":
		shutil.move(supportDir + helpDir[0], supportDir + "pythondocs")
		helpDir = supportDir + "pythondocs"
	else:
		helpDir = supportDir + helpDir[0]

	# create a list of files & create the keyword database
	for top, names in walktree(helpDir):	
		for file in names:
			# skip any hidden files (DS_STORE)
			if file.startswith("."):
				continue
			
			fileExt = os.path.splitext(file)[1]
			
			# we only really want html files
			# there are some files types that we don't need that are contained in the python documenation
			if fileExt == ".css" or fileExt == '.txt' or fileExt == '.png' or fileExt == '.gif':
				continue
						
			# walk through all the files
			# if we find a file, index it (add it to the sqlite keyword database)
			# if we find a directory index the structure of it
			# we dont need to iterate through the files in the directory manually since the walk covers all files
			# this makes it easier to handle files and folders seperatly
			
			filePath = os.path.join(top, file)
			if not os.path.isdir(filePath):
				createIndexForFile(filePath)
			else:
				createTreeForDirectory(filePath)

	# write out the xml structure
	open(supportDir + 'structure.xml', "w").write(xmlTree.tostring(xmlIndex))

	# print xmlTree.tostring(xmlIndex)
	# print fileList
	dbFile = supportDir + "keywords.db"

	if os.path.exists(dbFile):
		os.remove(dbFile)

	db = sqlite3.connect(dbFile)
	db.execute("CREATE TABLE keyword_index (keyword text, type text, page_name text, filename text)")
	db.executemany("INSERT INTO keyword_index (keyword, type, page_name, filename) values (?, ?, ?, ?)", [globalIndex[item] for item in globalIndex])
	# for aClass in db.execute("select * from keyword_index where type = 'module'"):
	#	  print aClass
	db.commit()

if __name__ == "__main__":
	main()
