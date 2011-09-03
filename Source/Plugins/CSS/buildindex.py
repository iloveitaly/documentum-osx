#!/usr/bin/python

import os, urllib, user, re, shutil, sys

if len(sys.argv) > 1:
	sys.path.append(sys.argv[1])
else:
	sys.path.append("/Users/Mike/Library/Application Support/PyHelp/pymodules")
	os.chdir("/Users/Mike/Library/Application Support/PyHelp/css")

import xml.etree.cElementTree as xmlTree

def main():
	propertyFinder = re.compile(r"\"http://www.w3.org/TR/REC-CSS2/(.*?)\">(.*?)</a>")
	tagRemover = re.compile(r"<.*?>.*?</.*?>")
	
	# the first line is for non-production
	supportDir = user.home + '/Library/Application Support/PyHelp/css/'
	#supportDir = os.path.realpath(os.getcwd()) + "/"
	
	rootNode = xmlTree.XML("<list/>")
	helpDir = filter(re.compile("css", re.IGNORECASE).search, os.listdir(supportDir))
	
	# make sure the dir containing the help files is named "cssdocs"
	if helpDir[0] != "cssdocs":
		shutil.move(supportDir + helpDir[0], supportDir + "cssdocs")
		helpDir = supportDir + "cssdocs"
	else:
		helpDir = supportDir + helpDir[0]
	
	propertyListPageContents = urllib.urlopen("http://meyerweb.com/eric/css/references/css2ref-prop-all.html").read()
	
	for match in propertyFinder.findall(propertyListPageContents):
		
		# split up the anchors 
		anchorIndex = match[0].find("#")
		
		if anchorIndex == -1:
			filePath = match[0]
			anchor = ""
		else:
			filePath = match[0][0:anchorIndex]
			anchor = match[0][anchorIndex + 1:]
		
		property = tagRemover.sub('', match[1]).strip()
		
		xmlTree.SubElement(rootNode, "level1", {'title':property, 'path':helpDir + "/" + filePath, 'anchor':anchor})
		
	open(supportDir + "structure.xml", "w").write(xmlTree.tostring(rootNode))

if __name__ == "__main__":
	main()