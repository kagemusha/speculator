class Stock
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :new_lows, :order=>:date.desc
  has_many :opinions
  embeds_many :balance_sheets
  embeds_many :income_statements
  embeds_many :cashflow_statements
  embeds_many :fin_calcs
  accepts_nested_attributes_for :balance_sheets
  accepts_nested_attributes_for :income_statements
  accepts_nested_attributes_for :cashflow_statements
  accepts_nested_attributes_for :fin_calcs

  field :symbol, type: String
  field :current_data, type: Hash
  field :exch, type: String
  field :fiscal_year, type: String
  field :sector, type: String
  field :company_name, type: String
  field :industry, type: String
  field :description, type: String
  field :company_url, type: String
  field :current_data_updated_at, type: DateTime
  field :bad_wsj_scrape, type: Boolean
  field :sequential, type: Boolean
  field :competitors, :type => Array
  validates_presence_of :symbol
  validates_uniqueness_of :symbol

  before_create :do_before_save

  def do_before_save
    self.symbol.upcase!
  end

  def current_data_current?
    !current_data.blank? and !current_data_updated_at.blank? and
        current_data_updated_at > Market.last_open_time
  end

  def fin_stmts(period_type=nil)
    Array.new.concat(balance_sheets).concat(income_statements).concat(cashflow_statements)
  end

  def clear_fin_stmts(period_type=nil)
    conditions = period_type ? {period_type: period_type} : nil

    balance_sheets.destroy_all conditions
    income_statements.destroy_all conditions
    cashflow_statements.destroy_all conditions
    fin_calcs.destroy_all conditions
  end

  def latest_q_date
    latest_q = balance_sheets.where(:period_type=>FinancialStatement::Q).desc(:period_end).first
    latest_q ? latest_q.period_end : Date.parse("2000-01-01")
  end

  def latest_a_date
    latest = balance_sheets.where(:period_type=>FinancialStatement::A).desc(:period_end).first
    latest ? latest.period_end : Date.parse("2000-01-01")
  end

  def latest_opinion
    opinions.desc(:updated_at).first
  end

  def latest_opinion_date
    latest = latest_opinion
    latest ? latest.updated_at : Time.parse("2000-01-01")
  end

  def no_current_interest
    recently_rated? and opinions.latest and opinions.latest.no_current_interest?
  end


  def update_current_data(data)
     update_attributes :current_data=>data, :current_data_updated_at=>Time.now
  end

  def bs_annual
    balance_sheets.where :period_type=>FinancialStatement::A
  end
  def bs_qtr
    balance_sheets.where :period_type=>FinancialStatement::Q
  end
  def pl_annual
    income_statements.where :period_type=>FinancialStatement::A
  end
  def calcs_annual
    fin_calcs.where :period_type=>FinancialStatement::A
  end
  def pl_qtr
    income_statements.where :period_type=>FinancialStatement::Q
  end
  def cf_annual
    cashflow_statements.where :period_type=>FinancialStatement::A
  end
  def cf_qtr
    cashflow_statements.where :period_type=>FinancialStatement::Q
  end
  def calcs_qtr
    fin_calcs.where :period_type=>FinancialStatement::Q
  end

  MIN_MKT_CAP =   100 #IN MILLIONS
  MIN_PRICE =     1.25

  def fix_float(prop, in_millions=true)
    print  "#{symbol}(#{prop}) "
    current_data ||= StockScrape.get_basic_data(self)
    amt = current_data[prop]
    return if !amt
    print  "#{amt} ->"
    if amt.class == String
      amt = convert_float(amt) * (amt.end_with?("B") ? 1000 : 1)
    end
    current_data[prop] = (in_millions and amt >= 1000000) ? amt/1000000 : amt
    puts current_data[prop]
    save
  end

  def recently_rated?
    return false if !latest_opinion
    (Time.now - latest_opinion_date) < 2.weeks
  end

  def no_interest_now
    last_opinion = latest_opinion
    return false if !last_opinion
    return false if (Time.now - last_opinion.updated_at) > 2.weeks
    last_opinion.no_current_interest
  end


  #def valid_short_target?
  #  valid_mkt_cap? and valid_price? and target_sector?
  #end

  def sufficient_mkt_cap?
    return true if !current_data
    mkt_cap = current_data["mkt cap"]
    return true if !mkt_cap
    if mkt_cap.class == String
      mult = mkt_cap.end_with?("B") ? 1000 : 1
      current_data["mkt cap"] = convert_float(mkt_cap) * mult
      save
    end
    return current_data["mkt cap"] > MIN_MKT_CAP
  end

  #looks like this might not matter, look at mkt cap instead
  #def sufficient_price?
  #  return true if !current_data or !current_data["price"]
  #  convert_float(current_data["price"]) > MIN_PRICE
  #end

  def convert_float(str)
    return nil if !str
    str.gsub! /[^0-9.]/, ""
    neg = str.match /\((.*?)\)/
    float = str.to_f
    neg ? -float : float
  end

  NON_TARGET_SECTORS = ["Equity Investment Instruments","Biotechnology", "Pharmaceuticals"]

  def non_short_target_sector?
    NON_TARGET_SECTORS.include?(sector)
  end

  def exclude_short?
    return "Not target Sector" if non_short_target_sector?
    return "Nuv Fund" if company_name and company_name.match /Nuveen(.*?)Fund/
    return "No data" if !sector and !industry and income_statements.length==0
    return "Insufficient mkt cap" if !sufficient_mkt_cap?
    return false
  end

  def not_short_target
    exclude_reason = exclude_short?
    return exclude_reason if exclude_reason
    return "No interest now" if no_interest_now
    return false
  end

  def adjust_units
    bs = balance_sheets ? balance_sheets[0] : nil
    inc = income_statements ? income_statements[0] : nil
    cf = cashflow_statements ? cashflow_statements[0] : nil
    return if (!bs and !inc) or !cf
    return if cf.units!=FinancialStatement::THOU
    if inc
      if inc.units==FinancialStatement::MIL
        make_cf_mil
      end
    elsif bs and bs.units==FinancialStatement::MIL
      make_cf_mil
    end
  end

  def make_cf_mil
    cashflow_statements.each do |stmt|
      next if stmt.units!=FinancialStatement::THOU
      next if stmt.scraped_data==nil
      stmt.scraped_data.each_pair do |key, val|
        stmt.scraped_data[key] = val/1000 if val
      end
      attrs = Hash.new
      WsjDataMappings::CF.each_pair do |attr, item|
        attrs[attr] = stmt.scraped_data[item]
      end
      stmt.update_attributes attrs
      stmt.units = FinancialStatement::MIL
      stmt.save
    end
  end

  #use latest period as std
  def unit_formats(type)
    #find statements
    #if sales[0]< 1000 and tot assets[0] < 1000
      #$xxx,xxx.x
    #else
      #$xxx,xxx
    #end
  end

  def rescrape(pushStatus=false)
    StockScrape.get_stock_data self, true, pushStatus
  end

  def recalc

    #create recalc statements
    income_statements.each do |stmt|
      self.fin_calcs.find_or_create_by({period_end: stmt.period_end, period_type: stmt.period_type})
      #calcs = stock.fin_calcs.where({period_end: stmt.period_end})
      #if !calcs
      #  Util.p "no fin calcs", stmt.period_end
      #  stock.fin_calcs.find_or_create_by({period_end: stmt.period_end, period_type: stmt.period_type})
      #end
    end

    [balance_sheets, income_statements, cashflow_statements, fin_calcs].each do |stmts|
      stmts.each do |stmt|
        Util.p "recalc", stmt.class.name, stmt.period_end
        stmt.recalc()
      end
    end
  end
end
