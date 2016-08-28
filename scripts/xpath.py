#!/usr/bin/python2
from lxml import html as xpathDoc
import sys
html = sys.stdin.read()
doc = xpathDoc.fromstring(html)
for rows in doc.xpath(sys.argv[1]):
    print str(rows)
