#!/usr/bin/python

# AS3 Download: http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3.zip
# AS2 Download: http://download.macromedia.com/pub/documentation/en/flash/mx2004/fl_actionscript_reference.zip
# more?		http://download.macromedia.com/pub/documentation/en/flash/fl8/flash_as2lr.zip
# ??			http://help.adobe.com/en_US/AS2LCR/Addendum_10.0/

#define ASXMLStructurePath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"structure.xml"]
#define ASKeywordDBPath [[[WHSupportFolder sharedController] supportFolderForPlugin:self] stringByAppendingPathComponent:@"keywords.db"]
#define ASHelpFilesDownloadURL @"http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3.zip"

#define XASH_FLASH_PATH_9 @"/Library/Application Support/Adobe/Flash CS3/en/Configuration/HelpPanel/Help/"
#define XASH_FLASH_PATH_8 @"/Users/Shared/Library/Application Support/Macromedia/Flash 8/en/Configuration/HelpPanel/Help/"
#define XASH_FLASH_PATH_7 @"/Users/Shared/Library/Application Support/Macromedia/Flash MX 2004/en/Configuration/HelpPanel/Help/"

#define XASH_FLASH_INDEX_9 @"file:///Library/Application Support/Adobe/Flash CS3/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"
#define XASH_FLASH_INDEX_8 @"file:///Users/Shared/Library/Application%20Support/Macromedia/Flash%208/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"
#define XASH_FLASH_INDEX_7 @"file:///Users/Shared/Library/Application%20Support/Macromedia/Flash%20MX2004/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"

#define TOC_PATH @"/help_toc.xml"

#define AS3XMLStructurePath @"/Users/Mike/Library/Application Support/Adobe/Flash CS3/en/Configuration/HelpPanel/Help/ProgrammingActionScript3/help_toc.xml"


import os, sys, user, re

# ====== CONFIGS DIR REFERENCES =======

PLUGIN_NAME = 'actionscript'
APP_NAME = 'PyHelp'
APP_SUPPORT_DIR = user.home + '/Library/Application Support/' + APP_NAME + '/'
PLUGIN_SUPPORT_DIR = APP_SUPPORT_DIR + PLUGIN_NAME + '/'
XML_STRUCTURE_FILE = PLUGIN_SUPPORT_DIR + 'structure.xml'

if len(sys.argv) > 2:
	sys.path.append(sys.argv[1])
	FLASH_HELP_DIR = sys.argv[2]
else:
	sys.path.append(APP_SUPPORT_DIR + "pymodules")
	os.chdir(PLUGIN_SUPPORT_DIR)
	FLASH_HELP_DIR = sys.argv[1]

# ====================================

#FLASH_HELP_DIR = user.home + '/Library/Application Support/Adobe/Flash CS3/en/Configuration/HelpPanel/Help/'
FLASH_HELP_TOC = "help_toc.xml"

titleFinder = re.compile(r'<book[^<]title="([^"]*)"')
bodyFinder = re.compile(r'(<book[^>]*>|</book>|\<\?xml[^?]*\?\>)')
linkNormalizer = re.compile(r'href="([^"]*)"')
anchorNormalizer = re.compile(r'href="([^#"]*)#?([^"]*)"')

# the dir referenced above contained a bunch of different sections with their our help structure

xmlOutput = '<?xml version="1.0" encoding="UTF-8"?><index>'

for fileName in os.listdir(FLASH_HELP_DIR):
	if not fileName.startswith("."):
		tocReference = FLASH_HELP_DIR + fileName + '/' + FLASH_HELP_TOC
		
		# we are only concerned with directories, but checking if a file exists 'inside' a file will do the same thing
		if os.path.exists(tocReference):
			tocData = open(tocReference, 'r').read()
			
			title = titleFinder.search(tocData).group(1)
			sectionPath = FLASH_HELP_DIR + fileName + '/'
			
			# we are going to manual XML since most of it is already done
			# maybe in the future add a home link here
			xmlOutput += "\n<section title=\"%s\" path=\"\" anchor=\"\">\n" % title
			
			sectionBody = bodyFinder.sub('', tocData)
			sectionBody = linkNormalizer.sub(('href="%s\\1"' % sectionPath), sectionBody)
			sectionBody = anchorNormalizer.sub(r'href="\1" anchor="\2"', sectionBody)

			xmlOutput += sectionBody
			
			xmlOutput += "\n</section>\n"
			
xmlOutput += "</index>"

xmlOutput = xmlOutput.replace("\n\n", '')

# write out the file
xmlHandle = open(XML_STRUCTURE_FILE, "w")
xmlHandle.write(xmlOutput)
xmlHandle.close()

sys.exit(0)