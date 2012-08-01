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

  #sample screp
  #"AUO", "AU Optronics ADS", "3.39", "$3.43", "-0.05", "-1.44", "587,373"
  def self.find_or_create_from_scrape(date, data)
    if stock ||= Stock.where(:symbol=>data[0]).first
      nlo = NewLow.where(:stock=>stock, :date=>date).first
      return nlo if nlo
    end
    create_from_scrape date, data
  end

  def self.create_from_scrape(date, data)
    nlo = NewLow.new
    nlo.date = date
    nlo.symbol = data[0]
    nlo.stock = Stock.find_or_create_by :symbol=>nlo.symbol
    nlo.company_name = data[1]
    nlo.new_low_price = data[2]
    nlo.price = data[3]
    nlo.chg = data[4]
    nlo.chg_pct = data[5]
    nlo.vol = data[6]
    nlo.save
    nlo
  end
end
