#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Grzegorz Adam Hankiewicz'
SITENAME = u'Rants from the Ballmer Peak'
SITEURL = 'http://gradha.github.io'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = u'en'

# Feed generation is usually not desired when developing
FEED_DOMAIN = SITEURL
FEED_ALL_ATOM = "feeds/all.atom.xml"
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
FEED_MAX_ITEMS = 10

# Blogroll
LINKS =  (('Idiot Toys', 'http://idiottoys.com'),
		('Kpop', 'http://www.reddit.com/r/kpop/'),
		('Gon Lamperouge', 'http://gonlamperouge.tumblr.com'),
		('FinoFIlipino', 'http://finofilipino.org'),
		)

# Social widget
SOCIAL = (('Nimrod', 'http://nimrod-code.org/news.xml'),
		('Nimrod forum posts', 'http://forum.nimrod-code.org/postActivity.xml'),)

DEFAULT_PAGINATION = 5

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True
