#!/usr/bin/python
import os, re, sys, user, shutil, urllib

if len(sys.argv) > 1:
	sys.path.append(sys.argv[1])
else:
	sys.path.append("/Users/Mike/Library/Application Support/PyHelp/pymodules")
	os.chdir("/Users/Mike/Library/Application Support/PyHelp/kohana")
	
from pysqlite2 import dbapi2 as sqlite3
import xml.etree.cElementTree as xmlTree
from BeautifulSoup import BeautifulSoup

baseURL = "http://docs.kohanaphp.com/"
linkFinder = re.compile(r'<a.*href="([^"]*)"[^>]*>([^<]+)</a>')
assetFinder = re.compile(r'(?:href|src)="([^"]+(js|css|png)[^"]*)"')
keywordFinder = re.compile(r'<h3><a.*?name="([^"]+)".*?>([^<]+)</a></h3>')
keywordDissector = re.compile(r'^([a-zA-Z .]+)?(?:: )?(.*)$')

# folder config
supportDir = user.home + '/Library/Application Support/PyHelp/kohana'
helpDir = supportDir

dbFile = supportDir + '/keywords.db'
xmlFile = supportDir + '/structure.xml'

if os.path.exists(dbFile):
	os.remove(dbFile)

globalKeywordList = []

# keyword finder:
# the keywords seem to not have a href in the link
# ex: <h3><a name="factory" id="factory">factory</a></h3>
# the same field is what is important

structureContents = urllib.urlopen(baseURL + "index.php").read()
indexContents = urllib.urlopen(baseURL + "contents?do=index").read()

# Structure Page: http://docs.kohanaphp.com/contents?do=index
# Index Page Links: <a href="/helpers/date" title="Date">Date</a>

fileConvertList = []
helpFileList = []
linkConvertList = []

# get assets
for link in assetFinder.findall(indexContents):
	fileName = link[0].strip("/").lower().replace("/", "-")
	downloadURL = baseURL + link[0].strip("/")
	
	# strip all query string vars, causing problems with local filesystem
	fileName = re.compile('\?|\&[^;]*\;|=').sub('', fileName)
	
	if fileName.find("css"):
		# then it is a css file
		# seems like the browser wants the css extension since text/css is sent by the browser
		# and text/plain is sent by the regular filename since there is no apache config on a local filesystem :P
		fileName = fileName.replace('.php', '')
		fileName = fileName + '.css'
	
	linkConvertList.append({'from':link[0], 'to':fileName})
	# print downloadURL
	urllib.urlretrieve(downloadURL, fileName.replace('&amp;', '&'))
	
# get css linked assets

# get help files
test = 0;
for link in linkFinder.findall(indexContents):
	if link[0].startswith("/"):
		# format: (link, name)
		fileName = link[0].strip("/").lower().replace("/", "-") + ".html"
		downloadURL = baseURL + link[0].strip("/")
		# print downloadURL
		urllib.urlretrieve(downloadURL, fileName)
		
		linkConvertList.append({'from':link[0], 'to':fileName})
		helpFileList.append({'file':fileName, 'name':link[1]})
		fileConvertList.append(fileName)

open("index.html", "w").write(structureContents)
fileConvertList.append("index.html")

def addKeyword(keyword, fileName, anchor):
	global globalKeywordList	
	globalKeywordList.append({'keyword':keyword, 'file':fileName, 'anchor':anchor})

# convert links to local links
for fileName in fileConvertList:
	fileContents = open(fileName, "r").read()
	
	# go throught the convert list
	for link in linkConvertList:
		fileContents = fileContents.replace('"' + link['from'] + '"', '"' + link['to'] + '"')

	for keyword in keywordFinder.findall(fileContents):
		print fileName
		addKeyword(keyword[1], helpDir + '/' + fileName, keyword[0])
	
	fileHandle = open(fileName, "w")
	fileHandle.write(fileContents)
	fileHandle.close()

# now get the structure
root = xmlTree.fromstring(BeautifulSoup(open("index.html").read(), ['html']).prettify())
rootNode = xmlTree.XML("<index/>")

# section finder
sections = root.xpath('//*[@class="column"]')
for section in sections:
	# grab the title, example column HTML:
	# <div class="column">
	# 		<h3>Overview</h3>
	# 		<ul>
	#			<li><a href="/overview" class="wikilink1" title="overview">What is Kohana?</a></li>
	# 			<li><a href="/overview/features" class="wikilink1" title="overview:features">Features</a></li>
	# 		</ul>
	# </div>
	
	sectionHTML = xmlTree.tostring(section)
	sectionName = re.compile(r"<h3>(.*?)</h3>").search(sectionHTML).group(1)
	
	if sectionName == "Info" or sectionName == "User Guide":
		continue;
	
	sectionNode = xmlTree.SubElement(rootNode, "section", {'title':sectionName, 'path':''})
	
	for subSection in re.compile(r'<a href="([^"]*)".*?title="([^"]*)"[^>]*>([^<]*)').findall(sectionHTML):
		if subSection[0][0] == '/':
			filePath = helpDir + subSection[0]
		else:
			filePath = helpDir + '/' + subSection[0]
		
		xmlTree.SubElement(sectionNode, "level1", {'title':subSection[2], 'path':filePath, 'anchor':subSection[1]})

# save structure and db info
db = sqlite3.connect(dbFile)
db.execute("CREATE TABLE keyword_index (keyword text, anchor text, filename text)")
db.executemany("INSERT INTO keyword_index (keyword, filename, anchor) values (:keyword, :file, :anchor)", globalKeywordList)
db.commit()
print xmlFile
open(xmlFile, "w").write(xmlTree.tostring(rootNode))

sys.exit()

dbDataList = []
xmlIndex = xmlTree.XML("<index/>")

# process orphans
categoryList['Core'] = []
for orphanKeyword in globalKeywordOrphanList:
	keyword = orphanKeyword['keyword']
	if keyword[0].lower() == keyword[0]:
		orphanKeyword['file'] = "index.html"
		categoryList['Core'].append(orphanKeyword)
	else:
		# then its not a proper keyword that should be included in a tree list but it
		# should still be included in the searching
		dbDataList.append((orphanKeyword['keyword'], '', orphanKeyword['anchor'], supportDir + orphanKeyword['file']))

for category in categoryList:
	newSection = xmlTree.SubElement(xmlIndex, "category", {'keyword':category, 'file':supportDir + categoryList[category][0]['file']})
	
	for keywordObject in categoryList[category]:
		keywordObject['file'] = supportDir + keywordObject['file']
		xmlTree.SubElement(newSection, 'keyword', keywordObject);
		dbDataList.append((keywordObject['keyword'], category, keywordObject['anchor'], keywordObject['file']))
		
db = sqlite3.connect(dbFile)
db.execute("CREATE TABLE keyword_index (keyword text, category text, anchor text, filename text)")
db.executemany("INSERT INTO keyword_index (keyword, category, anchor, filename) values (?, ?, ?, ?)", dbDataList)
# for aClass in db.execute("select * from keyword_index"):
# 	  print aClass
db.commit()

open(xmlFile, "w").write(xmlTree.tostring(xmlIndex))

# print categoryList

def main():
	propertyFinder = re.compile(r"\"http://www.w3.org/TR/REC-CSS2/(.*?)\">(.*?)</a>")
	tagRemover = re.compile(r"<.*?>.*?</.*?>")
	
	# the first line is for non-production
	supportDir = user.home + '/Library/Application Support/PyHelp/kohana/'
	#supportDir = os.path.realpath(os.getcwd()) + "/"
	
	rootNode = xmlTree.XML("<list/>")
	helpDir = filter(re.compile("css", re.IGNORECASE).search, os.listdir(supportDir))
	
	# make sure the dir containing the help files is named "cssdocs"
	if helpDir[0] != "cssdocs":
		shutil.move(supportDir + helpDir[0], supportDir + "cssdocs")
		helpDir = supportDir + "cssdocs"
	else:
		helpDir = supportDir + helpDir[0]
	
	helpOutlinePage = urllib.urlopen("http://docs.kohanaphp.com/").read()
	indexPage = urllib.urlopen("http://docs.kohanaphp.com/contents?do=index").read()
	
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
		
		xmlTree.SubElement(rootNode, "property", {'title':property, 'path':helpDir + "/" + filePath, 'anchor':anchor})
		
	open(supportDir + "structure.xml", "w").write(xmlTree.tostring(rootNode))
