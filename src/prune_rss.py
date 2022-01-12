#!/usr/bin/env python3
# -*- coding: utf-8 -*-


from bs4 import BeautifulSoup
import glob
import os
import os.path
import xml.etree.ElementTree as ET

# https://stackoverflow.com/a/8998773/172690
ET.register_namespace('', "http://www.w3.org/2005/Atom")

RSS="../feed.xml"
TMP="/tmp/feed.xml"
before = open(RSS, "rb").read()

tree = ET.parse(RSS)
root = tree.getroot()

HARD_LIMIT = 2000
SOFT_LIMIT = 1500

def ns(s): return '{http://www.w3.org/2005/Atom}' + s

def reduce_html(random_input, total_size):
    if len(random_input) < 10:
        print("Bailing out!")
        sys.exit(1)

    parsed_html = BeautifulSoup(random_input + "...")
    return (str(parsed_html) + str(len(parsed_html)) + " bytes out of "
        + str(total_size) + ".")


for entry in root.iter(ns("entry")):
    for child in entry.iter(ns("content")):
        if len(child.text) >= 2000:
            child.text = reduce_html(child.text[:SOFT_LIMIT], len(child.text))
        #print child.text[:1500] + "\n-\n"

tree.write(TMP, encoding="utf-8", xml_declaration = True)
# LOL, etree generates wrong xml for ellipsis, so we need to get rid of it.
after = open(TMP, "r").read().replace("…", "...")

if before != after:
    print("Xml changed")
    open(RSS, "w").write(after)
