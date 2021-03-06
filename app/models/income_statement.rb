class IncomeStatement < FinancialStatement
#:sales,:sales_growth,:net_inc,:ebitda, :ebitda_growth=>0.0, :unusual_exp=>67.0,
#:eps_diluted, :cogs,:da_expense=, :gross_inc, :sga, :rd,
#:interest_exp, :tax, :unusual_expense=>67.0, :units=>"Millions", :currency=>"USD"

  field :sales, type: Float
  field :sales_growth, type: Float
  field :cogs, type: Float
  field :da_expense, type: Float
  field :unusual_exp, type: Float
  field :gross_inc, type: Float
  field :sga, type: Float
  field :rd, type: Float
  field :interest_exp, type: Float
  field :tax, type: Float
  field :net_inc, type: Float
  field :eps_diluted, type: Float
  field :ebitda, type: Float
  field :ebitda_growth, type: Float
  field :ebda, type: Float

  #WSJ_MAPPINGS = {:sales=>"Sales/Revenue",:sales_growth=>"Sales Growth",
  #            :net_inc=>"Net Income Available to Common",:ebitda=>"EBITDA",
  #            :ebitda_growth=>"EBITDA Growth",:unusual_exp=>"Unusual Expense",:eps_diluted=>"EPS (Diluted)",
  #            :cogs=>"Cost of Goods Sold (COGS) incl. D&A",
  #            :da_expense=>"Depreciation & Amortization Expense",
  #            :gross_inc=>"Gross Income", :sga=>"SG&A Expense", :rd=>"Research & Development",
  #            :interest_exp=>"Interest Expense", :tax=>"Income Tax", :unusual_expense=>"Unusual Expense"
  #}

  def recalc()
    if ebitda and interest_exp and tax
      self.ebda = ebitda - interest_exp - tax
    end
  end

end
