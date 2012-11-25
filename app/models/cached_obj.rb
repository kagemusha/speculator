class CachedObj
  include Mongoid::Document
  include Mongoid::Timestamps

  field :label, type: String
  field :expiration, type: DateTime
  field :object

  COAL_TABLE = "coal_table"
  def self.coal_table
    cachedTbl = CachedObj.where(label: COAL_TABLE).first
    if cachedTbl and Time.now < cachedTbl.expiration #and false #for testing
      cachedTbl.object
    else
      tbl, last_date = MktDataScraper.coal_table
      exp = Market.tz_nyc.parse(last_date)+10.days+7.hours
      Util.p "screped new coal teble expires", exp
      CachedObj.create({label: COAL_TABLE, object: tbl, expiration: exp})
      tbl
    end
  end

end
