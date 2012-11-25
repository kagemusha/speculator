namespace :new_lows do
  desc "scrape new lows from the wsj"
  task :scrape => :environment do    #without :environment, doesn't load app dir'
    Util.p "Scraping new lows..."
    NewLowScraper.do
    Util.p "Scraped new lows"
  end

  desc "daily scrape"
  task :daily_scrape => :environment do    #without :environment, doesn't load app dir'
    dayOfWeek = Time.now.day
    if dayOfWeek!=0 and dayOfWeek!=1
      StockScrape.do
      Util.p "Scraped new lows"
    end
  end


end
