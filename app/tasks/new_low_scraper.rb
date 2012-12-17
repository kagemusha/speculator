require 'nokogiri'
require 'open-uri'
require 'date'

class NewLowScraper
  NEW_LO_BASE_URL = "http://online.wsj.com/mdc/public/page/2_3021-newhi"
  QUOTE_BASE_URL = "http://quotes.wsj.com"
  EXCHANGES = ["nyse","nnm"]

  def self.scrape(date=nil)
    if date and (date.saturday? or date.sunday?)
      pr "Can't scrape for weekend"
      return
    end

    EXCHANGES.each do |exch|
      url = new_lows_url exch, date
      pr "=====Getting NEW LOW SYMBOLS for #{exch}======"
      pr " ----- Url", url, "---------"
      page = Nokogiri::HTML(open url)
      if !(data_date ||= get_data_date(page))
        pr "Couldn't verify date on New Lows Page.  Check!!  Exiting..."
        return
      end
      get_new_lows(page, data_date)
    end
  end

  def self.get_new_lows(page, data_date)
    lows_count = get_lows_count page
    hi_lo_rows = page.css "table.mdcTable tr"
    tot_rows = hi_lo_rows.length
    hi_lo_rows[tot_rows-lows_count..tot_rows].map do |row|
      low = get_new_low_data_array(row)
      save_new_low(low, data_date)
    end
  end

  def self.get_lows_count(page)
    page.css("td").each do |elem|
      match = elem.text.match /New 52-Week Lows: (.*?)/
      return elem.text.split(": ")[1].to_i if match
    end
  end

  def self.get_new_low_data_array(elem)
    elem = elem.text.split("\n")
    symbol = /^(.*?)\((.*?)\)/.match(elem[2])[2]
    [symbol, elem[1], elem[5..9]].flatten
  end

  def self.save_new_low(low, data_date)
    symbol = low[0]
    if valid_symbol?(symbol)
      begin
        pr "Screping: #{symbol}"
        pr "Creating new low.."
        new_low = find_or_create_from_scrape data_date, low
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

  def self.get_data_date(page)
    match = page.to_s.match /var tableDate=\"(.*?)\";</
    pr "deet", "|#{match[1]}|", match[1].class.name, match.inspect
    match ? Date.strptime(match[1], '%m/%d/%Y') : Time.now
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

  #sample screp
  #"AUO", "AU Optronics ADS", "3.39", "$3.43", "-0.05", "-1.44", "587,373"
  def self.find_or_create_from_scrape(date, data)
    if stock ||= Stock.where(:symbol=>data[0]).first
      nlo = NewLow.where(:stock=>stock, :date=>date).first
      return nlo if nlo
    end
    create_from_scrape date, data
  end

  def self.create_from_scrape(date, data)
    nlo = NewLow.new
    nlo.date = date
    nlo.symbol = data[0]
    nlo.stock = Stock.find_or_create_by :symbol=>nlo.symbol
    nlo.company_name = data[1]
    nlo.new_low_price = data[2]
    nlo.price = data[3]
    nlo.chg = data[4]
    nlo.chg_pct = data[5]
    nlo.vol = data[6]
    nlo.save
    nlo
  end

  #def self.get_data_date_test(date=nil)
  #  date = Date.parse(date) if date
  #  page = Nokogiri::HTML(open new_lows_url("nyse",date))
  #  get_data_date page
  #end


end