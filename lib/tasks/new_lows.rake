namespace :new_lows do
  desc "scrape new lows from the wsj"
  task :scrape => :environment do    #without :environment, doesn't load app dir'
    StockScrape.do
    Util.p "Scraped new lows"
  end
end
