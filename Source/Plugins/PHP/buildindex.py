#!/usr/bin/python

import os, urllib, user, re, shutil, sys, os.path
from types import *

if len(sys.argv) > 1:
	# print sys.argv[1]
	sys.path.append(sys.argv[1])

import xml.etree.cElementTree as xmlTree

def processBranch(branch, xmlBranch, level = 1):
	global helpDir
	
	# go through all the items in the branch
	for item in branch:
		if type(branch[item]) == ListType:
			# if it is a list, then we have reached the end of the execution
			# empty out the list into the xml structure
			
			tempLevel = level
			
			# again, if there is only one item in the branch, why branch?
			if len(branch[item]) == 1:
				newBranch = xmlBranch
			else:
				#print item
				newBranch = xmlTree.SubElement(xmlBranch, "level" + str(tempLevel), {"title":item});
				tempLevel += 1
			
			for fileOb in branch[item]:
				xmlTree.SubElement(newBranch, "level" + str(tempLevel), fileOb)
		else:
			if len(branch[item].keys()) == 1:
				# if there is only one item in the branch
				# we can skip it, since it really isnt branching at all
				processBranch(branch[item], xmlBranch, level)
			else:
				# check if class file exists for this item
				if os.path.exists(os.path.join(helpDir, 'class.' + item + '.html')):
					filePath = os.path.join(helpDir, 'class.' + item + '.html')
				else:
					filePath = os.path.join(helpDir, "index.html")
				
				newBranch = xmlTree.SubElement(xmlBranch, "level" + str(level), {"title":item, "path":filePath});
				processBranch(branch[item], newBranch, level + 1)

def main():
	global helpDir
	
	# the first line is for debug
	supportDir = user.home + '/Library/Application Support/PyHelp/php/'
	#supportDir = os.path.realpath(os.getcwd()) + "/"

	fileIndex = {}
	rootNode = xmlTree.XML("<list/>")
	
	helpDir = filter(re.compile("php", re.IGNORECASE).search, os.listdir(supportDir))
	
	# make sure the dir containing the help files is named "cssdocs"
	if not helpDir:
		shutil.move(supportDir + "html", supportDir + "phpdocs")
		helpDir = supportDir + "phpdocs"
	else:
		helpDir = supportDir + helpDir[0]
	
	for file in os.listdir(helpDir):
		if not file.startswith("."):
			# split up the file into parts seperated by "."
			# loop through each of the peices
			# each peice is a branch in the tree
			
			fileParts = file.split(".")
			fileParts.pop() # get rid of the .html

			partLen = len(fileParts)
			relRef = fileIndex
			
			for x in range(partLen):
				if x != partLen - 1:
					if type(relRef) == ListType:
						continue
					
					if not relRef.has_key(fileParts[x]):
						relRef[fileParts[x]] = {}
					relRef = relRef[fileParts[x]]
				else:
					# sometimes the functions are categorized by the - in the last part of their name
					# sometimes its just the name of the function/method/class/whatever
					
					nameParts = fileParts[x].split("-")
					namePartsLen = len(nameParts)

					for y in range(namePartsLen):
						if y == namePartsLen - 1:
							if type(relRef) == DictType:
								relRef[nameParts[y]] = []
								relRef = relRef[nameParts[y]]
							relRef.append({"title":fileParts[x].replace("-", "_"), "path":os.path.join(helpDir, file)})
						else:
							if type(relRef) == ListType:
								break
						
							if not relRef.has_key(nameParts[y]):
								relRef[nameParts[y]] = {}
															
							relRef = relRef[nameParts[y]]
			
	#print fileIndex
	processBranch(fileIndex, rootNode)
	open(supportDir + "structure.xml", "w").write(xmlTree.tostring(rootNode))

if __name__ == "__main__":
	main()