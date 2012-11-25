class WsjDataMappings

  NEW_LO_BASE_URL = "http://online.wsj.com/mdc/public/page/2_3021-newhi"
  QUOTE_BASE_URL = "http://quotes.wsj.com"
  EXCHANGES = ["nyse","nnm"]
  PERIOD_TYPES = {FinancialStatement::A=>"annual", FinancialStatement::Q=>"quarter"}
  NEW_LO_TEXT = "New 52-Week Lows"


  PL =  {
      :sales=>"Sales/Revenue",
      :sales_growth=>"Sales Growth",
      :net_inc=>"Net Income Available to Common",
      :ebitda=>"EBITDA",
      :ebitda_growth=>"EBITDA Growth",
      :unusual_exp=>"Unusual Expense",
      :eps_diluted=>"EPS (Diluted)",
      :cogs=>"Cost of Goods Sold (COGS) incl. D&A",
      :da_expense=>"Depreciation & Amortization Expense",
      :gross_inc=>"Gross Income", :sga=>"SG&A Expense", :rd=>"Research & Development",
      :interest_exp=>"Interest Expense",
      :tax=>"Income Tax",
      :unusual_exp=>"Unusual Expense"
  }

  CF = {
      :depreciation=>"Depreciation, Depletion & Amortization",
      :funds_from_ops=>"Funds from Operations",
      :op_cf=>"Net Operating Cash Flow",
      :capex=>"Capital Expenditures",
      :net_asset_acqs=>"Net Assets from Acquisitions",
      :asset_sales=>"Sale of Fixed Assets & Businesses",
      :invest_cf=>"Net Investing Cash Flow",
      :debt_chg=>"Issuance/Reduction of Debt, Net",
      :divs_paid=>"Cash Dividends Paid - Total",
      :finance_cf=>"Net Financing Cash Flow",
      :cap_stock_chg => "Change in Capital Stock",
      :free_cf=>"Free Cash Flow"
  }

  BS = {:cash_and_st_inv=>"Cash & Short Term Investments",
        :acct_rec=>"Total Accounts Receivable",
        :inventories=>"Inventories",
        :tot_cur_assets=>"Total Current Assets",
        :ppe=>"Net Property, Plant & Equipment",
        :land=>"Land & Improvements",
        :lt_inv=>"Total Investments and Advances",
        :intangibles=>"Intangible Assets",
        :tot_assets=>"Total Assets",
        :tot_cur_liab=>"Total Current Liabilities",
        :lt_debt=>"Long-Term Debt",
        :charge_provision=>"Provision for Risks & Charges",
        :tot_liab=>"Total Liabilities"
  }

  BS_SPECS = {:klass=>BalanceSheet, :attr=>"balance_sheets", :abbr=>"bs", :url_frag=> "balance-sheet", :attr_conversions=>BS, :table_count=>3}
  PL_SPECS = {:klass=>IncomeStatement, :attr=>"income_statements", :abbr=>"pl", :url_frag=> "income-statement", :attr_conversions=>PL, :table_count=>2}
  CF_SPECS = {:klass=>CashflowStatement, :attr=>"cashflow_statements", :abbr=>"cf", :url_frag=> "cash-flow", :attr_conversions=>CF, :table_count=>3}

  TABLE_CLASS = "crDataTable"

  def self.financials_url(symbol, stmt_type, period_type)
    page = "financials/#{PERIOD_TYPES[period_type]}/#{stmt_type}"
    symbol_url symbol, page
  end

  def self.symbol_url(symbol, page="")
    symbol = symbol.symbol if symbol.class == Stock
    #pr "symbolurl", symbol
    "#{QUOTE_BASE_URL}/#{symbol}/#{page}"
  end

  UNITS_MIL = "millions"
  UNITS_BIL = "billions"
  UNITS_THOU = "thousands"
  #convert everything into million of whatever currency
  def self.multiplier(units_str)
    return 1 if units_str.blank? or units_str.downcase==UNITS_MIL
    return 0.001 if units_str.downcase==UNITS_THOU.downcase
    1000 #UNITS_BIL
  end


end
