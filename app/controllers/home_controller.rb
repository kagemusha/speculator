class HomeController < ApplicationController

  def index
    #@last_scrape = Scrape.where label: "mkt_data"
    latest_data = MktDataScraper.scrape_tiles
    #Util.p "@latest_data", latest_data.inspect
  end

  def mkt_data
    @data = MktDataScraper.scrape
    Util.p "@data @data @data @data @data @data @data "
    @data.each_pair {|k,v| Util.p(k,v)}
    @bb_commods = MktDataScraper.scrape_bb_commods
    update_date @data, @bb_commods
    Util.p "@bb_commods @bb_commods @bb_commods @bb_commods"
    @bb_commods.each_pair {|k,v| Util.p(k,v)}
    @coal_table = CachedObj.coal_table
    render partial: "data_panel", locals: {data: @data}
  end

  private

  UPDATES = {"West Texas Intermediate, Cushing"=>"WTI",
             "Engelhard industrial bullion"=>"GOLD",
             "(U.S.$ equivalent)"=>"SILVER",
             "Copper, high grade: Comex spot price $ per lb."=>"COPPER",
             "Natural gas Henry Hub, $ per MMbtu"=>"NATURAL"
      }

  def update_date(data, latest_data)
    #Util.p "latest_data", latest_data
    UPDATES.each_pair do |old_field, new_field|
      begin
        Util.p "oldf, newf", old_field, new_field
        #amt = StockScrape.convert_float(latest_data[new_field][:amt])
        #chg = StockScrape.convert_float(latest_data[new_field][:chg])
        latest_array = latest_data[new_field]
        #Util.p "latdat", latest_data[new_field].class.name, latest_data[new_field].length, latest_data[new_field]
        Util.p "latdatarray",latest_array.length, latest_array
        amt = latest_data[new_field][0].to_f_f
        chg = latest_data[new_field][1].to_f_f
        if new_field=="COPPER"
          amt /= 100
          chg /= 100
        end
        old_price = amt - chg
        #Util.p "amts", amt, chg, old_price
        data[old_field][2] = amt
        data[old_field][3] = old_price
        #Util.p "new data", data[old_field][2],data[old_field][3]
      rescue Exception=>e
        Util.p e.message
      end
    end
  end


  def scrape_mkt_data

  end

end
