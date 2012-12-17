namespace :new_lows do
  #e.g. rake new_lows:scrape
  #e.g. rake new_lows:scrape date=2012-11-25
  desc "scrape new lows from the wsj"
  task :scrape, [:date] => :environment do    #without :environment, doesn't load app dir'
    puts "date #{ENV['date']}"
    date   = ENV['date'] ? Date.parse(ENV['date']) : nil
    p "Scraping new lows...#{date || "last trading day"}"
    NewLowScraper.scrape(date)
    p "Scraped new lows "
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
