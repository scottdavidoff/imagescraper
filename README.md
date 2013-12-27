imagescraper
============

rails utility to scrape images from craigslist.org

this utility scrapes images and text from the personal ads on craigslist. i created this to support the work of artist t. foley for her project "on display." 


usage
========================

Scraper.new(constant gender, array cities)

Scraper.new(Scraper.MEN,[ "austin", "miami" ])


usage explained
========================

models/Scraper.rb is the file that does all the work

the gender of posters to be scraped is encoded as a constant that is passed to the constructor.

gender = {
	men => 		Scraper.MEN,
	women => 	Scraper.WOMEN,
	both =>		Scraper.Both
}

personals on craigslist are organized by city. the cities to be scraped are encoded as an array passed to the constructor. parameters mirror city names encoded in craigslist URLs.

cities = [
  "austin",
  "miami",
  "atlanta",
  "washingtondc"
  ]


notes on the art project
========================
t.foley's art project uses images and text from personal ads to explore how men and women differently represent their ideal relationship using online dating.

there is an academic treatment of identity
https://vimeo.com/17137667

and there is an artistic re-enactment of selected ads
https://vimeo.com/35062193

please note: while scraping is sometimes an acceptable tactic for gathering data online for analysis, it needs to be used with discretion. scraping can place heavy loads on servers, which is not in the public good. and the data gathered also need to be handled responsibly

t. foley's work scrupulously maintains the anonymity of craigslist posters.
