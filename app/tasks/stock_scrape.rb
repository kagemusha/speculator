require 'nokogiri'
require 'open-uri'
require 'date'

class StockScrape

  NEW_LO_BASE_URL = "http://online.wsj.com/mdc/public/page/2_3021-newhi"
  QUOTE_BASE_URL = "http://quotes.wsj.com"
  EXCHANGES = ["nyse","nnm"]
  PERIOD_TYPES = {FinancialStatement::A=>"annual", FinancialStatement::Q=>"quarter"}
  NEW_LO_TEXT = "New 52-Week Lows"

  BS_SPECS = {:klass=>BalanceSheet, :attr=>"balance_sheets",:url_frag=> "balance-sheet", :attr_conversions=>BalanceSheet::WSJ_MAPPINGS}
  PL_SPECS = {:klass=>IncomeStatement, :attr=>"income_statements", :url_frag=> "income-statement", :attr_conversions=>IncomeStatement::WSJ_MAPPINGS}
  CF_SPECS = {:klass=>CashflowStatement, :attr=>"cashflow_statements", :url_frag=> "cash-flow", :attr_conversions=>CashflowStatement::WSJ_MAPPINGS}


  def self.do(date=nil)
    data_date, new_lows = get_new_lows(date)
    new_lows.each_pair do |exch, lows|
      pr exch, lows.inspect
      lows.each do |low|
        symbol = low[0]
        if valid_symbol?(symbol)
          pr ""
          #begin
            pr "Screping: #{symbol}"
            basic_data = get_basic_data symbol
            pr "Creating new low.."
            new_low = NewLow.find_or_create_from_scrape data_date, low
            stock = new_low.stock
            stock.update_current_data basic_data
            pr "Getting stock data.."
            get_stock_data stock
            pr "#{symbol} done"
          #rescue Exception => e
          #  puts e.message
          #  puts e.backtrace.inspect
          #end
        end
      end
    end
  end


def self.scrape_symbol(symbol)
  basic_data = get_basic_data symbol
  pr "Creating new low.."
  stock = Stock.new :symbol=>symbol
  stock.update_current_data basic_data
  pr "Getting stock data.."
  get_stock_data stock
  stock
end


  def self.get_new_lows(data_date=nil)
    new_lows = Hash.new
    EXCHANGES.each do |exch|
      url = new_lows_url exch, data_date
      #pr "Url", url
      page = get_page url
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
    data_hash["short ratio"] = convert_float data[45]
    data_hash["short pct float"] = convert_float data[46]
    data_hash["short shares prior"] = convert_mb data[47]
    pr "get_basic_data", data_hash
    data_hash
  end

  def self.convert_mb(str)
    return nil if !str
    mult = str.end_with?("B") ? 1000 : 1
    convert_float(str) * mult
  end

  def self.convert_float(str)
    return nil if !str
    #debug_str = str.clone
    neg = str.match /\((.*?)\)/
    str.gsub! /[^0-9.-]/, ""
    float = str.to_f
    #pr("Yen", debug_str, float) if debug_str.include? ""
    neg ? -float : float
  end
  #get_symbol_sample_pages "bpi"


  def self.valid_symbol?(symbol)
    #valid if only has letters
    !/[^a-zA-Z]/.match(symbol)
  end

  def self.get_stock_data(stock, force=false)
    stock.bad_wsj_scrape = false
    get_profile_data stock

    #abc just placeholders since don't really need the data here
    q_periods,a,b,c = get_statement_params stock, PL_SPECS[:url_frag], PERIOD_TYPES[FinancialStatement::Q]
    an_periods,a,b,c = get_statement_params stock, PL_SPECS[:url_frag], PERIOD_TYPES[FinancialStatement::A]
    pr "q_pers", q_periods
    pr "a_pers", an_periods
    if q_periods.length==0
      if an_periods.length==0
        pr "Unable to get periods -- skipping reports"
        stock.bad_wsj_scrape = true
        stock.save
        return
      else
        last_a = Date.parse("#{an_periods.last}-01-01")
        if !force and stock.latest_a_date >= last_a
          pr "Reports up to date -- skipping reports"
          stock.save
          return
        else
          pr "Getting reports"
        end
      end
    else
      last_q = Date.parse(q_periods.last)
      if !force and stock.latest_q_date >= last_q
        pr "Reports up to date -- skipping reports"
        stock.save
        return
      else
        pr "Getting reports"
      end
    end
    get_financial_statement_data stock, BS_SPECS
    get_financial_statement_data stock, PL_SPECS
    get_financial_statement_data stock, CF_SPECS
    q_periods.each do |per_end|
      stock.fin_calcs.find_or_create_by(period_end: per_end, period_type: FinancialStatement::Q).recalc()
    end
    an_periods.each do |per_end|
      per_end += "-12-31"
      stock.fin_calcs.find_or_create_by(period_end: per_end, period_type: FinancialStatement::A).recalc()
    end
    stock.adjust_units
    stock.save
  end

  def self.get_profile_data(stock)
    data_hash = Hash.new
    url = symbol_url(stock.symbol, "company-people")
    #pr "get profd", url
    page = get_page url
    stock.company_name = page.css("a#cr_name_id").text
    stock.description = page.css("#cr_company_desc").text
    stock.exch = page.css(".cr_quoteHeader abbr").to_s.upcase.include?("NYSE") ? "NYSE" : "NASD"
    page.css(".cr_data_field").each do |field|
      label = field.css(".data_lbl").text.strip
      val = field.css(".data_data").text.strip
      #pr "profdata", label, val
      data_hash[label] = val
    end
    stock.industry = data_hash["Industry"]
    stock.sector = data_hash["Sector"]
    data_hash
  end

  def self.get_statement_params(stock, stmt_type, period)
    url = financials_url stock.symbol, stmt_type, period
    page = get_page url
    periods = page.css("th")
    units_line = periods.shift.to_s
    #p "units_line", units_line
    match = units_line.match /Fiscal year is (.*?). All values (.*?)\s+(.*?)$/
    #p "cur match", units_line, match.inspect
    periods_array = periods[0..4].map {|p| p.text}
    if match
      units = match[3] ? match[3][0] : nil
      return periods_array, match[1], units, match[2] #periods,fiscal_year,units,currency
    else
      return periods_array, nil, nil, nil #periods,fiscal_year,units,currency
    end
  end


  def self.fiscal_item(hash, data)
    data_array = data.text.split("\n")
    #pr "fi",  data_array.inspect
    item = data_array.shift.strip
    dat = data_array[0..4].map {|d| d.strip}
    #pr "itemdata", "|#{item}|", dat
    hash[item] = dat
  end

  ROW_CLASSES = ["totalRow", "empRow","mainRow", "childRow","rowLevel-2","rowLevel-3"]

  def self.get_financial_statement_data(stock, stmt_specs)
    PERIOD_TYPES.each_pair do |key, period_type|
      url = financials_url stock.symbol, stmt_specs[:url_frag], period_type
      pr stock.symbol, period_type, stmt_specs[:url_frag], url
      page = get_page url
      items_hash = Hash.new
      ROW_CLASSES.each do |klass|
        items = page.css "tr.#{klass}"
        items.each do |item|
          fiscal_item items_hash, item
        end
      end
      periods,fy,units,currency =
        get_statement_params stock, stmt_specs[:url_frag], period_type
      stock.fiscal_year = fy
      periods.each_with_index do |period, i|
        period += "-12-31" if period_type==PERIOD_TYPES[FinancialStatement::A]
        end_date = Date.parse period
        #pr "REPORTz", stock.symbol, stmt_specs[:klass].name, period_type, end_date
        attrs, raw_attrs = parse_attrs items_hash, stmt_specs[:attr_conversions], i
        stmts = eval "stock.#{stmt_specs[:attr]}"
        stmt = stmts.find_or_initialize_by(:period_end=>end_date, :period_type=>key)
        #pr "has bs?", stmt.id
        attrs[:fiscal_year] = fy
        attrs[:units] = units
        attrs[:currency] = currency
        #attrs[:scraped_data] = raw_attrs #this doesn't seem to work
        stmt.update_attributes attrs
        stmt.scraped_data = raw_attrs
        stmt.save
      end
    end
    #p hash.inspect
  end


  def self.get_units_currency(stock, stmt_spec, period)
    url = financials_url stock.symbol, stmt_spec[:url_frag], period
    #pr "periodz url", url
    page = get_page url
    periods = page.css("th")
    #pr "proidz", periods.text

  end



  def self.parse_attrs(items_hash, mappings, i)
    raw_vals = Hash.new
    attrs = Hash.new
    items_hash.each_pair do |item, vals|
      #pr "attr,val", attr, val
      raw_vals[item] = convert_float(vals[i])
    end
    mappings.each_pair do |attr, item|
      attrs[attr] = raw_vals[item]
    end
    return attrs, raw_vals
  end

  def self.pr_fin_item(item, hash)
    return if !hash
    data = hash[item]
    return if !data
    printf "  %-45s %12s %12s %12s %12s %12s\n", item, data[0], data[1], data[2], data[3], data[4]
  end

  DISPLAY_PARAMS = [
      ["Balance Sheet", @bs_hash, BalanceSheet::WSJ_MAPPINGS],
      ["Income",  @pl_hash, IncomeStatement::WSJ_MAPPINGS],
      ["Cash Flow", @cf_hash, CashflowStatement::WSJ_MAPPINGS]
  ]

  BASIC_DISPLAY_FIELDS =["price","","mkt cap","","Industry","Sector", "",
   "shares out","float", "", "short shares", "short ratio", "short pct float"]


  def self.get_data_date(page)
    dateDivSpans = page.css "div.tbltime span"
    dateText = dateDivSpans.pop.text
    #pr dateText
    date = /^(.*?)\s+(.*?)\s+(.*?),\s+(.*?)\s/.match dateText
    Date.parse "#{date[2]} #{date[3]} #{date[4]}"
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


  def self.new_lows_url(exch="nyse",date=nil)
    mod = date ? "mdc_pastcalendar" : "topnav_2_3002"
    date_str = date ? date.strftime("%Y%m%d") : ""
    "#{NEW_LO_BASE_URL}#{exch}-newhighs-#{date_str}.html?mod=#{mod}"
  end

  def self.symbol_url(symbol, page="")
    symbol = symbol.symbol if symbol.class == Stock
    #pr "symbolurl", symbol
    "#{QUOTE_BASE_URL}/#{symbol}/#{page}"
  end

  def self.yahoo_url(symbol)
    "http://finance.yahoo.com/q/ks?s=#{symbol}+Key+Statistics"
  end

  def self.financials_url(symbol, type, term)
    page = "financials/#{term}/#{type}"
    symbol_url symbol, page
  end

  def self.get_page(url)
    #pr "getting page", url
    Nokogiri::HTML(open url)
  end

  def self.write_sample_page(file_name, page)
    p "Writing #{file_name}..."
    file = File.new "sample_pages/#{file_name}.html", "w"
    file.puts page
  end

  def self.get_symbol_sample_pages(symbol)
    write_sample_page "#{symbol}-basic", get_page(symbol_url symbol)
    write_sample_page "#{symbol}-company_profile", get_page(symbol_url symbol, "company-people")
    write_sample_page "#{symbol}-ratios", get_page(financials_url symbol, "", "")
    STMT_TYPES.each_value do |sType|
      PERIOD_TYPES.each_value do |term|
        write_sample_page "#{symbol}-#{sType}-#{term}", get_page(financials_url symbol, sType, term)
      end
    end
  end



end