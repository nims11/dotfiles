#!/usr/bin/python
from lxml import html as xpathDoc
import sys
html = sys.stdin.read()
doc = xpathDoc.fromstring(html.encode())
for rows in doc.xpath(sys.argv[1]):
    print(str(rows))
