#/bin/bash

# Make sure the cwd is the PyHelp application support folder

mkdir pymodules

# Download sqlite?
wget http://oss.itsystementwicklung.de/download/pysqlite/2.4/2.4.1/pysqlite-2.4.1.tar.gz
# python setup.py install --install-lib /Users/Mike/Library/Application\ Support/PyHelp/pymodules/ --install-data /Users/Mike/Library/Application\ Support/PyHelp/pymodules/

# Download beautiful soup
wget http://www.crummy.com/software/BeautifulSoup/download/BeautifulSoup.tar.gz
tar xf BeautifulSoup.tar.gz
cp BeautifulSoup-3.1.0.1/BeautifulSoup.py ./
rm -R BeautifulSoup-3.1.0.1
rm BeautifulSoup.tar.gz

# Download elementtree
wget http://effbot.org/media/downloads/elementtree-1.2.6-20050316.tar.gz
python setup.py install --install-lib /Users/Mike/Library/Application\ Support/PyHelp/modules