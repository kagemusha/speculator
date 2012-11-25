require 'nokogiri'
require 'open-uri'
require 'date'

class StockScrape

  #NEW_LO_TEXT = "New 52-Week Lows"

  #BS_SPECS = {:klass=>BalanceSheet, :attr=>"balance_sheets",:url_frag=> "balance-sheet", :attr_conversions=>WsjDataMappings::BS}
  #PL_SPECS = {:klass=>IncomeStatement, :attr=>"income_statements", :url_frag=> "income-statement", :attr_conversions=>WsjDataMappings::PL}
  #CF_SPECS = {:klass=>CashflowStatement, :attr=>"cashflow_statements", :url_frag=> "cash-flow", :attr_conversions=>WsjDataMappings::CF}



  def self.scrape_symbol(symbol)
    pr "Creating new low.."
    stock = Stock.new :symbol=>symbol
    pr "Getting stock data.."
    get_stock_data stock
    stock
  end

  def self.add_basic_data(stock)
    basic_data = get_basic_data stock.symbol
    stock.update_current_data basic_data
  end

  def self.get_basic_data(symbol)
    symbol = symbol.symbol if symbol.class==Stock
    data_hash = Hash.new
    url = yahoo_url(symbol)
    pr "getting basic data", symbol, url
    page = get_page url
    price_match = /yfs_l84_(.*?)">(.*?)</.match(page.to_s)
    data_hash["price"] = price_match ? price_match[2] : nil
    data = page.css("td.yfnc_tabledata1").map {|item| item.text}

    data_hash["mkt cap"] = convert_mb(data[0])
    data_hash["shares out"] = convert_mb data[40]
    data_hash["float"] = convert_mb data[41]
    data_hash["short shares"] = convert_mb data[44]
    data_hash["short ratio"] = Util.convert_float data[45]
    data_hash["short pct float"] = Util.convert_float data[46]
    data_hash["short shares prior"] = convert_mb data[47]
    #pr "get_basic_data", data_hash
    data_hash
  end

  def self.convert_mb(str)
    return nil if !str
    mult = str.end_with?("B") ? 1000 : 1
    Util.convert_float(str) * mult
  end

  #get_symbol_sample_pages "bpi"



  def self.get_stock_data(stock, force=false, pushStatus=false)
    pr "get_stock_data(force)", force
    stock.bad_wsj_scrape = false
    add_basic_data stock
    ProfileDataScraper.add_data stock
    #begin
      FinStmtScraper.get_stmts(stock, force)
      pr "finstmt screped"
    #rescue Exception=>e
    #  pr "#{stock.symbol}: No data!!"
    #  stock.bad_wsj_scrape = true
    #  stock.save
    #end
  end



  def self.fiscal_item(hash, data)
    data_array = data.text.split("\n")
    #pr "fi",  data_array.inspect
    item = data_array.shift.strip
    dat = data_array[0..5].map {|d| d.strip}
    dat.shift()
    #pr "itemdata", "|#{item}|", "[#{dat}]"
    hash[item] = dat
  end

  #ROW_CLASSES = ["totalRow", "empRow","mainRow", "childRow","rowLevel-2","rowLevel-3"]








  def self.get_mult(units)
    if units == FinancialStatement::THOU
      0.001
    elsif units == FinancialStatement::BIL
      1000
    else
      1
    end
  end


  def self.pr_fin_item(item, hash)
    return if !hash
    data = hash[item]
    return if !data
    printf "  %-45s %12s %12s %12s %12s %12s\n", item, data[0], data[1], data[2], data[3], data[4]
  end



  def self.pr(label, *msg)
    msgStr = msg.empty? ? "#{label}" : "#{label}: "+ msg.join(", ")
    Util.p msgStr
    print "#{msgStr}\n"
  end

  def self.prn(label, *msg)
    msgStr = msg.empty? ? "#{label}" : "#{label}: "+ msg.join(", ")
    print msgStr
  end

  def self.yahoo_url(symbol)
    "http://finance.yahoo.com/q/ks?s=#{symbol}+Key+Statistics"
  end

  #def self.financials_url(symbol, type, term)
  #  page = "financials/#{term}/#{type}"
  #  symbol_url symbol, page
  #end

  def self.get_page(url)
    #pr "getting page", url
    Nokogiri::HTML(open url)
  end

  def self.write_sample_page(file_name, page)
    p "Writing #{file_name}..."
    file = File.new "sample_pages/#{file_name}.html", "w"
    file.puts page
  end


end



