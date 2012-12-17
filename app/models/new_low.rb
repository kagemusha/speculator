class NewLow
  include Mongoid::Document
  belongs_to :stock
  field :symbol, type: String
  field :date, type: Date
  field :company_name, type: String
  field :new_low_price, type: Float
  field :price, type: Float
  field :chg, type: Float
  field :chg_pct, type: Float
  field :vol, type: Integer
  index({ date: -1 })
  default_scope order_by(:date => :desc)

  def self.latest
    puts "wip autoloadpaths", Rails.application.config.autoload_paths
    latest_date = self.max(:date)
    puts "latest date", latest_date
    self.where :date=>latest_date
  end

end
