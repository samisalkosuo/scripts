import time
from time import mktime
from datetime import datetime
import feedparser
import re
import sys

#Script to convert RSS feeds to tab-separated CSV
#retrieves RSS feeds from YLE

#Python3, may not work with Python2

# RSS URLs
rssurls = {
    'yle_pääuutiset': 'https://feeds.yle.fi/uutiset/v1/majorHeadlines/YLE_UUTISET.rss',
    'yle_tuoreimmat': 'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET',
    'yle_kotimaa':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-34837',
    'yle_ulkomaat':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-34953',
    'yle_talous':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-19274',
    'yle_politiikka':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-38033',
    'yle_kulttuuri':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-150067',
    'yle_viihde':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-36066',
    'yle_tiede':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-819',
    'yle_luonto':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-35354',
    'yle_terveys':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-35138',
    'yle_media':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-35057',
    'yle_liikenne':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-12',
    'yle_näkökulmat':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-35381',
    'yle_etelä-karjala':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-141372',
    'yle_etelä-pohjanmaa':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-146311',
    'yle_etelä-savo':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-141852',
    'yle_kainuu':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-141399',
    'yle_kanta-häme':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-138727',
    'yle_keski-pohjanmaa':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-135629',
    'yle_keski-suomi':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-148148',
    'yle_kymenlaakso':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-131408',
    'yle_lappi':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-139752',
    'yle_pirkanmaa':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-146831',
    'yle_pohjanmaa':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-148149',
    'yle_pohjois-karjala':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-141936',
    'yle_pohjois-pohjanmaa':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-148154',
    'yle_pohjois-savo':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-141764',
    'yle_päijät-häme':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-141401',
    'yle_satakunta':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-139772',
    'yle_uusimaa':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-147345',
    'yle_varsinais-suomi':'https://feeds.yle.fi/uutiset/v1/recent.rss?publisherIds=YLE_UUTISET&concepts=18-135507'
    
    }

#populate this and check if exists, no duplicate items
allPublishedTimes=[]

#remove all tags
regx = re.compile('<.*?>')
def removetags(text):
  txt = re.sub(regx, '', text)
  return txt

def parse_rss(rss_url):
    return feedparser.parse(rss_url)

#just to make sure that fields do not have newlines or tabs or extra whitespaces
def clean_str(str):
  return str.replace("\r\n"," ").replace("\n"," ").replace("\t"," ").strip()

#datetime format (Wed, 23 Aug 2017 12:51:00 +0300)
formatString="%a, %d %b %Y %H:%M:%S %z"
def rss2csv( rss_url ):
    feed = parse_rss( rss_url )
    for item in feed.entries:
      #print(item)
      
      published=str(datetime.fromtimestamp(mktime(time.strptime(item.published, formatString))))
      try:
        if not published in allPublishedTimes:
          allPublishedTimes.append(published)
          tags=[]
          #category might be same as first tag
          #if item.category:
          #  tags.append(item.category)
          for tag in item.tags:
            tags.append(clean_str(tag.term))
          tags=",".join(tags)
          title=clean_str(removetags(item.title))
          summary=clean_str(removetags(item.summary))
          content=clean_str(removetags(item.content[0].value))

          if not title.endswith("."):
            title="%s." % title
          if not summary.endswith("."):
            summary="%s." % summary
          if not content.endswith("."):
            content="%s." % content
          #CSV format, tab-separated fields:
          #time,tags(categories),combined(title,summary,content)
          print("%s\t%s\t%s %s %s" % (published,tags,title,summary,content))          

          #break
      except:
        #ignore error
        #print("%s\tError" % published)
        pass


for key,url in rssurls.items():
    rss2csv(url)
    #break


