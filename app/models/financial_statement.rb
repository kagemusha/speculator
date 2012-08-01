class FinancialStatement
  include Mongoid::Document
  embedded_in :stock
  field :period_type, type: String #quarter or annual
  field :period_end, type: Date
  field :units, type: String
  field :fiscal_year, type: String
  field :currency, type: String
  field :scraped_data, type: Hash
  before_save :recalc

  BIL = "B"
  MIL = "M"
  THOU = "T"

  A = "a" #annual
  Q = "q" #quarterly

  def label(attr)
    attr.to_s.gsub("_"," ").capitalize
  end

  def formatted_period
    annual? ? period_end.year : period_end.to_s("%Y-%m-%d")
  end

  def annual?
    period_type==A
  end

  def update_and_recalc(attr)
    self.update_attributes attrs
    recalc()
  end

  def recalc()
    #overwrite in subclass
  end
end
