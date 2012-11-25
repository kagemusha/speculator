require 'nokogiri'
require 'open-uri'
require 'date'

class NewLowScraper
  NEW_LO_BASE_URL = "http://online.wsj.com/mdc/public/page/2_3021-newhi"
  QUOTE_BASE_URL = "http://quotes.wsj.com"
  EXCHANGES = ["nyse","nnm"]

  def self.do(date=nil)
    Util.p "Stock Scrape"
    data_date, new_lows = get_new_lows(date)
    new_lows.each_pair do |exch, lows|
      pr exch, lows.inspect
      lows.each do |low|
        symbol = low[0]
        if valid_symbol?(symbol)
          begin
            pr "Screping: #{symbol}"
            pr "Creating new low.."
            new_low = NewLow.find_or_create_from_scrape data_date, low
            stock = new_low.stock
            pr "Getting stock data.."
            StockScrape.get_stock_data stock
            pr "#{symbol} done"
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
          end
        end
      end
    end
  end

  def self.get_new_lows(data_date=nil)
    new_lows = Hash.new
    EXCHANGES.each do |exch|
      url = new_lows_url exch, data_date
      pr "=====Getting NEW LOW SYMBOLS for #{exch}======"
      pr " ----- Url", url, "---------"
      page = Nokogiri::HTML(open url)
      data_date = get_data_date page
      lows_count = get_lows_count page
      symbols = page.css "table.mdcTable tr"
      symbols = symbols[symbols.length-(lows_count)..symbols.length]
      new_lows[exch] = symbols.map do |s|
        s = s.text.split("\n")
        symbol = /^(.*?)\((.*?)\)/.match(s[2])[2]
        [symbol, s[1], s[5..9]].flatten
      end
    end
    return data_date, new_lows
  end

  def self.get_lows_count(page)
    page.css("td").each do |elem|
      match = elem.text.match /New 52-Week Lows: (.*?)/
      return elem.text.split(": ")[1].to_i if match
    end
  end

  def self.get_data_date(page)
    dateDivSpans = page.css "div.tbltime span"
    dateText = dateDivSpans.pop.text
    #pr "get_data_data: #{dateText}"
    date = /^(.*?)\s+(.*?)\s+(.*?),\s+(.*?)\s/.match dateText
    Date.parse "#{date[2]} #{date[3]} #{date[4]}"
  end

  def self.new_lows_url(exch="nyse",date=nil)
    mod = date ? "mdc_pastcalendar" : "topnav_2_3002"
    date_str = date ? date.strftime("%Y%m%d") : ""
    "#{NEW_LO_BASE_URL}#{exch}-newhighs-#{date_str}.html?mod=#{mod}"
  end


  def self.valid_symbol?(symbol)
    #valid if only has letters
    !/[^a-zA-Z]/.match(symbol)
  end

  def self.pr(label, *msg)
    msgStr = msg.empty? ? "#{label}" : "#{label}: "+ msg.join(", ")
    Util.p msgStr
    print "#{msgStr}\n"
  end




end