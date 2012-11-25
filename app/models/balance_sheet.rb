class BalanceSheet < FinancialStatement
  #attrszz: {:cash_and_st_inv=>66644.0, :acct_rec=>9871.0,
  #:inventories=>1624.0, :tot_cur_assets=>84051.0,
  #:ppe=>8329.0, :land=>nil, :lt_inv=>10038.0,
  #:intangibles=>17889.0, :tot_assets=>121876.0,
  #:tot_cur_liab=>31402.0, :lt_debt=>9714.0, :charge_provision=>7800.0,
  #:tot_liab=>53040.0, :currency=>"USD"}

  field :cash_and_st_inv, type: Float
  field :acct_rec, type: Float
  field :inventories, type: Float
  field :tot_cur_assets, type: Float
  field :ppe, type: Float
  field :land, type: Float
  field :lt_inv, type: Float
  field :intangibles, type: Float
  field :tot_assets, type: Float
  field :tot_cur_liab, type: Float
  field :lt_debt, type: Float
  field :charge_provision, type: Float
  field :tot_liab, type: Float
  field :tang_assets, type: Float #calced
  field :net_eq, type: Float #calced   #obsolete
  field :net_tang_eq, type: Float #calced

  #WSJ_MAPPINGS = {:cash_and_st_inv=>"Cash & Short Term Investments", :acct_rec=>"Total Accounts Receivable",
  #            :inventories=>"Inventories", :tot_cur_assets=>"Total Current Assets",
  #            :ppe=>"Net Property, Plant & Equipment",:land=>"Land & Improvements",
  #            :lt_inv=>"Total Investments and Advances",:intangibles=>"Intangible Assets",
  #            :tot_assets=>"Total Assets", :tot_cur_liab=>"Total Current Liabilities",
  #            :lt_debt=>"Long-Term Debt",:charge_provision=>"Provision for Risks & Charges",
  #            :tot_liab=>"Total Liabilities"}

  def recalc()
    if tot_assets and intangibles and tot_liab
      self.tang_assets = tot_assets - intangibles
      self.net_tang_eq = self.net_eq = tang_assets - tot_liab
    end
  end

end
