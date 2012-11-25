class CashflowStatement < FinancialStatement
#attrszz: :depreciation, :funds_from_ops, :op_cf, :capex, :net_asset_acqs,
#:asset_sales, :invest_cf, :debt_chg, :divs_paid, :finance_cf,
#:cap_stock_chg, :free_cf, :currency

  field :depreciation, type: Float
  field :funds_from_ops, type: Float
  field :capex, type: Float
  field :chg_in_working_cap, type: Float
  field :op_cf, type: Float
  field :net_asset_acqs, type: Float
  field :assets_sales, type: Float
  field :net_asset_inv, type: Float #calced
  field :investments_chg, type: Float
  field :invest_cf, type: Float
  field :divs_paid, type: Float
  field :debt_chg, type: Float
  field :cap_stock_chg, type: Float
  field :finance_cf, type: Float
  field :free_cf, type: Float

  #WSJ_MAPPINGS = {:depreciation=>"Depreciation, Depletion & Amortization",:funds_from_ops=>"Funds from Operations",
  #            :op_cf=>"Net Operating Cash Flow",:capex=>"Capital Expenditures",
  #            :net_asset_acqs=>"Net Assets from Acquisitions",:asset_sales=>"Sale of Fixed Assets & Businesses",
  #            :invest_cf=>"Net Investing Cash Flow",:debt_chg=>"Issuance/Reduction of Debt, Net",
  #            :divs_paid=>"Cash Dividends Paid - Total",:finance_cf=>"Net Financing Cash Flow",
  #            :cap_stock_chg => "Change in Capital Stock", :free_cf=>"Free Cash Flow" }

  def recalc()
    self.net_asset_inv = - (net_asset_acqs + asset_sales)   if (net_asset_acqs and asset_sales)
    self.capex = capex.abs if capex
  end

end
