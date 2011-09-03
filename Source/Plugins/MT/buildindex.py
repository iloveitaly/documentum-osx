#!/usr/bin/python

import os, re, sys, user, shutil, urllib

if len(sys.argv) > 1:
	sys.path.append(sys.argv[1])
else:
	sys.path.append("/Users/Mike/Library/Application Support/PyHelp/pymodules")
	os.chdir("/Users/Mike/Library/Application Support/PyHelp/mt")
	
from pysqlite2 import dbapi2 as sqlite3
import xml.etree.cElementTree as xmlTree

# from BeautifulSoup import BeautifulSoup

# index url: http://docs.mootools.net/
# menu content: <div id="Menu">
# page content: <div id="Content">

def addKeyword(matches, fileName, anchor):
	global categoryList, globalKeywordList, globalKeywordOrphanList
	
	if matches[1] == '':
		category = ''
		keyword = matches[0]
	else:
		keyword = matches[1]
		category = matches[0]
	
	if category == '':
		# check if the keyword exists already in the keyword list
		# we need the flat orphan list to avoid duplicate orphans
		
		if not keyword in globalKeywordList and not keyword in globalKeywordOrphanFlatList:
			globalKeywordOrphanList.append({'title':keyword, 'path':fileName, 'anchor':anchor})
			globalKeywordOrphanFlatList.append(keyword)
	else:
		if keyword in globalKeywordList:
			#print "Duplicate: " + keyword + " : " + category
			return
		
		# create a new category for it
		if not categoryList.has_key(category):
			categoryList[category] = []
		
		categoryList[category].append({'title':keyword, 'path':fileName, 'anchor':anchor})
		
		globalKeywordList.append(keyword)

baseURL = "http://mootools.net/"
linkFinder = re.compile(r'<a href="([^#][^"]+)">([^<]+)</a>')
assetFinder = re.compile(r'"([^"]+\.(js|css|png))"')
keywordFinder = re.compile(r'<a href="(#[^"]+)">([^<]+)</a>')
keywordDissector = re.compile(r'^([a-zA-Z .]+)?(?:: )?(.*)$')
indexContents = urllib.urlopen(baseURL + "docs/").read()

fileConvertList = []
helpFileList = []
linkConvertList = []

categoryList = {}
globalKeywordList = []
globalKeywordOrphanList = []
globalKeywordOrphanFlatList = []

# get assets
for link in assetFinder.findall(indexContents):
	fileName = link[0].strip("/").lower().replace("/", "-")
	downloadURL = baseURL + link[0].strip("/")
	linkConvertList.append({'from':link[0], 'to':fileName})
	urllib.urlretrieve(downloadURL, fileName)
	
# get css linked assets

# get help files
for link in linkFinder.findall(indexContents):
	if not link[0].startswith("http://"):
		# format: (link, name)
		fileName = link[0].strip("/").lower().replace("/", "-") + ".html"
		downloadURL = baseURL + link[0].strip("/")
		urllib.urlretrieve(downloadURL, fileName)
		
		linkConvertList.append({'from':link[0], 'to':fileName})
		helpFileList.append({'file':fileName, 'name':link[1]})
		fileConvertList.append(fileName)

open("index.html", "w").write(indexContents)
fileConvertList.append("index.html")

# convert links to local links
for fileName in fileConvertList:
	fileContents = open(fileName, "r").read()
	
	for link in linkConvertList:
		fileContents = fileContents.replace('"' + link['from'] + '"', '"' + link['to'] + '"')
	
	for keyword in keywordFinder.findall(fileContents):
		# (link, name) where link is an anchor

		matches = keywordDissector.match(keyword[1]).groups()

		# if matches[1] (match 2) is empty then it has no specified parent and is part of core
		# otherwise match 2 is the keyword category
		
		# some keywords that don't contain a category are just links to a keyword and not an actual keyword
		# these should be removed in favor of the real keywords
		addKeyword(matches, fileName, keyword[0])
	
	fileHandle = open(fileName, "w")
	fileHandle.write(fileContents)
	fileHandle.close()

# setup the db
supportDir = user.home + '/Library/Application Support/PyHelp/mt/'

dbFile = supportDir + "keywords.db"
xmlFile = supportDir + 'structure.xml'

if os.path.exists(dbFile):
	os.remove(dbFile)

dbDataList = []
xmlIndex = xmlTree.XML("<index/>")

# process orphans
categoryList['Core'] = []
for orphanKeyword in globalKeywordOrphanList:
	keyword = orphanKeyword['title']
	if keyword[0].lower() == keyword[0]:
		orphanKeyword['path'] = "index.html"
		categoryList['Core'].append(orphanKeyword)
	else:
		# then its not a proper keyword that should be included in a tree list but it
		# should still be included in the searching
		dbDataList.append((orphanKeyword['title'], '', orphanKeyword['anchor'], supportDir + orphanKeyword['path']))

for category in categoryList:
	newSection = xmlTree.SubElement(xmlIndex, "section", {'title':category, 'path':supportDir + categoryList[category][0]['path']})
	
	for keywordObject in categoryList[category]:
		keywordObject['path'] = supportDir + keywordObject['path']
		xmlTree.SubElement(newSection, 'level1', keywordObject);
		dbDataList.append((keywordObject['title'], category, keywordObject['anchor'], keywordObject['path']))
		
db = sqlite3.connect(dbFile)
db.execute("CREATE TABLE keyword_index (keyword text, category text, anchor text, filename text)")
db.executemany("INSERT INTO keyword_index (keyword, category, anchor, filename) values (?, ?, ?, ?)", dbDataList)
db.commit()

open(xmlFile, "w").write(xmlTree.tostring(xmlIndex))

sys.exit(0)