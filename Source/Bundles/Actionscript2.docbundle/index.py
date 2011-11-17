import os, sys, re

# DC_BUNDLE + DC_FOLDER
DC_FOLDER = os.getenv("DC_FOLDER")
XML_STRUCTURE_FILE = os.path.join(DC_FOLDER, 'structure.xml')
FLASH_HELP_DIR = os.path.join(DC_FOLDER, "docs")
FLASH_HELP_TOC = "help_toc.xml"

titleFinder = re.compile(r'<book[^<]title="([^"]*)"')
bodyFinder = re.compile(r'(<book[^>]*>|</book>|\<\?xml[^?]*\?\>)')
linkNormalizer = re.compile(r'href="([^"]*)"')
anchorNormalizer = re.compile(r'href="([^#"]*)#?([^"]*)"')

# the dir referenced above contained a bunch of different sections with their our help structure

xmlOutput = '<?xml version="1.0" encoding="UTF-8"?><index>'

for fileName in os.listdir(FLASH_HELP_DIR):
	if not fileName.startswith("."):
		tocReference = os.path.join(FLASH_HELP_DIR, fileName, FLASH_HELP_TOC)
		
		# we are only concerned with directories, but checking if a file exists 'inside' a file will do the same thing
		if os.path.exists(tocReference):
			tocData = open(tocReference, 'r').read()
			
			title = titleFinder.search(tocData).group(1)
			sectionPath = os.path.join(FLASH_HELP_DIR, fileName)
			
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
