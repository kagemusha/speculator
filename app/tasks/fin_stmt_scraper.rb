require 'nokogiri'
require 'open-uri'
require 'date'

class FinStmtScraper

  SPECS = [WsjDataMappings::BS_SPECS,WsjDataMappings::PL_SPECS,WsjDataMappings::CF_SPECS]
  PERIOD_TYPES = {FinancialStatement::A=>"annual", FinancialStatement::Q=>"quarter"}

  def self.get_stmts(stock, force=false)
    SPECS.each do |stmt_spec|
      #Util.p "specs", stmt_spec[:abbr]
      #Util.p "pertypes", FinancialStatement::PERIOD_TYPES.inspect
      FinancialStatement::PERIOD_TYPES.each do |period_type|
        #Util.p "period_type", period_type
        get_data stock, stmt_spec, period_type, force
      end
    end
    stock.recalc()
  end

  def self.get_data(stock, stmt_specs, period_type, force=false)
    Util.p "get_financial_statement_data(stock,type,period_type,force)",
       stock.symbol,stmt_specs[:abbr], period_type,force
    url = WsjDataMappings.financials_url stock.symbol, stmt_specs[:url_frag], period_type
    page = Nokogiri::HTML(open url)
    tables = TableScraper.page_tables_to_arrays page
    return if !tables or !tables[0]
    first_row = tables[0].shift
    periods, fy_end_month, currency, units = get_stmt_params(period_type, first_row)
    1.upto(5) do |i|
      if period_type==FinancialStatement::A
        period = last_day_of_fiscal_year periods[i-1], fy_end_month
      else
        period = Date.parse periods[i-1]
      end
      #break if fin_stmt exists and not force
      mult = WsjDataMappings.multiplier units
      raw_data_hash, data_hash = get_data_hash stmt_specs, tables, i, mult
      #Util.p "=====",stock.symbol,stmt_specs[:attr],period_type,period,"======"
      #Util.p data_hash.inspect
      create_stmt stock, stmt_specs, raw_data_hash, data_hash, period_type, period, currency, units
      #stock.fin_calcs.find_or_create_by(period_end: period, period_type: period_type).recalc()
    end
  end

  def self.create_stmt(stock, stmt_specs, raw_attrs, attrs, period_type, end_date, currency, units)
    #Util.p "REPORTz", stock.symbol, stmt_specs[:klass].name, period_type, end_date
    stmts = eval "stock.#{stmt_specs[:attr]}"
    stmt = stmts.find_or_initialize_by(:period_end=>end_date, :period_type=>period_type)
    attrs[:currency] = currency
    #Util.p "attrszz", attrs
    stmt.update_attributes! attrs
    stmt.scraped_data = raw_attrs   #attrs[:scraped_data] = raw_attrs #this doesn't seem to work
    stmt.save
    #Util.p "stmtzz", stmt.inspect
    #Util.p "stockzz(bs,pl,cf lengths)", stock.balance_sheets.length, stock.income_statements.length, stock.cashflow_statements.length
  end

  def self.get_data_hash(spec, tables, column, mult=1) #use mult to adjust all to millions
    raw_data = Hash.new
    tables.each do |tbl|
      tbl.each { |row| raw_data[row[0]] = Util.convert_float(row[ column])*mult }
    end
    #if column==1
    #  puts "Raw Data"
    #  puts raw_data.inspect
    #end
    data = Hash.new
    spec[:attr_conversions].each_pair do |key, val|
      data[key] = raw_data[val] || 0.0
    end
    return raw_data, data
  end

  def self.last_day_of_fiscal_year(year, month_string)
    month = Date::MONTHNAMES.index(month_string)
    Date.new(year.to_i, month, -1)
  end

  def self.get_stmt_params(period_type, header_line)
    #puts "hline #{header_line.inspect}"
    units_cell = header_line.shift
    match = units_cell.match /Fiscal year is (.*?)-(.*?). All values (.*?)\s+(.*?)\.$/
    #p "cur match",  match.inspect
    header_line.pop
    #periods_array = periods[0..4].map {|p| p.text}
    if match
      fiscal_yr_end_month = match[2]
      currency = match[3]
      units = match[4] #? match[3][0] : nil
      return header_line, fiscal_yr_end_month, currency , units
    else
      return periods, nil, nil, nil #periods,fiscal_year,units,currency
    end
  end


  def self.get_units_currency(stock, stmt_spec, period)
    url = financials_url stock.symbol, stmt_spec[:url_frag], period
    #Util.p "periodz url", url
    page = Nokogiri::HTML(open url)
    periods = page.css("th")
    #Util.p "proidz", periods.text

  end


end

