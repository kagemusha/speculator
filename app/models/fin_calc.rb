class FinCalc < FinancialStatement
  field :wgt_sales_tang_assets, type: Float

  def recalc
    bs = stock.balance_sheets.where(period_end: period_end, period_type: period_type ).first
    inc_st = stock.income_statements.where(period_end: period_end, period_type: period_type).first
    return if !bs or !inc_st
    self.wgt_sales_tang_assets = inc_st.sales and bs.tang_assets and bs.tang_assets != 0 ? inc_st.sales/bs.tang_assets : nil
  end

end
