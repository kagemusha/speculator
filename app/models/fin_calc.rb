class FinCalc < FinancialStatement
  field :wgt_sales_tang_assets, type: Float
  field :m_cashflow, type: Float #attempts to take all real non-financial bus tx into acct
    #differs from FCF in that int, tax included, working cap excluded


  def recalc
    bs = stock.balance_sheets.where(period_end: period_end, period_type: period_type ).first
    is = stock.income_statements.where(period_end: period_end, period_type: period_type).first
    cs = stock.cashflow_statements.where(period_end: period_end, period_type: period_type).first
    if is and cs
      Util.p "finrecalc (#{period_end}) ebda, capex, net_asset_inv", is.ebda, cs.capex, cs.net_asset_inv
      if is.ebda and cs.capex and cs.net_asset_inv
        self.m_cashflow = is.ebda - cs.capex - cs.net_asset_inv
        #p "finrecalc mcf: #{self.m_cashflow}"
      end
    else
      #p "finrecalc is: #{!is ? " nil":"exists"}, cs: #{!cs ? " nil":"exists"}"
    end
    if bs and is
      self.wgt_sales_tang_assets = is.sales and bs.tang_assets and bs.tang_assets != 0 ? is.sales/bs.tang_assets : nil
    end
  end

end
