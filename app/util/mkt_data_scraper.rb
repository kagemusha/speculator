require 'nokogiri'
require 'open-uri'
require 'date'

class MktDataScraper
  BLOOMBERG_URL = "http://www.bloomberg.com/markets/"
  BLOOMBERG_COMMODS_URL = "http://www.bloomberg.com/markets/commodities/futures/"
  WSJ_COMMODS_URL = "http://online.wsj.com/mdc/public/page/2_3023-cashprices.html?mod=mdc_cmd_cash"
  EIA_COAL_URL = "http://www.eia.gov/coal/news_markets/"
  def self.scrape
    items = scrape_mkts
    corrects = Hash.new
    items.each_pair do |key, val|
       if key.include? "FUTURE"
         (key_array ||= key.split).pop
         corrects[key_array.join] = val
         items.delete key
       end
    end
    #Util.p corrects.inspect
    items.merge! corrects
    items.merge scrape_commodities
  end


  def self.coal_table
    Util.p "Scrape coaltbl"
    page =  Nokogiri::HTML(open EIA_COAL_URL)
    #page =  Nokogiri::HTML(File.open "/Users/michael/Dropbox/rails_proj/speculator/doc/bloomberg-mkt.html")
    table = page.css(".simpletable")
    source_td = table.at_css("td.source")
    source_td.content = ""
    while (date_node = table.at_css("td.lightrow[align='left']"))
      Util.p "datenod", date_node.content
      date = date_node.content
      date_node.content =  Date.parse(date).strftime("%b %d")
      date_node['class'] = ""
    end
    return table.to_s, date
  end

  def self.scrape_mkts
    page =  Nokogiri::HTML(open BLOOMBERG_URL)
    #page =  Nokogiri::HTML(File.open "/Users/michael/Dropbox/rails_proj/speculator/doc/bloomberg-mkt.html")
    items = Hash.new
    data_rows = page.css(".dual_border_data_table tr")
    data_rows.each do |row|
      row_array = row.text.split("\n")
      row_array = row_array.map {|item| item.strip}
      row_array.delete ""
      #Util.p row_array.inspect
      items[row_array.shift]=row_array
    end
    items
  end

  def self.scrape_commodities
    Util.p "screping commods"
    page =  Nokogiri::HTML open(WSJ_COMMODS_URL)
    #Util.p page.to_s
    items = Hash.new
    data_rows = page.css("tr")
    data_rows.each do |row|
      row_array = row.text.split("\n")
      row_array = row_array.map {|item| item.strip}
      row_array.delete ""
      #Util.p row_array.inspect
      add_item items, row_array
    end
    items
  end

  ENGEL = "Engelhard industrial bullion"
  def self.add_item(items, row_array)
    label = row_array.shift
    label = "SILVER BULLION" if (label==ENGEL and items[ENGEL])
    items[label]=row_array
  end

  def self.scrape_tiles
    page =  Nokogiri::HTML(open BLOOMBERG_URL)
    items = Hash.new
    tiles = page.css(".tile")
    tiles.each do |tile|
      item = tile.css(".ticker").text
      amt = tile.css(".volume").text
      chg = tile.css(".change").text
      down = !tile.css(".change.down").text.blank?
      chg = "#{down ? "-":"+"}#{chg}"
      items[item] = {amt: amt, chg: chg}
    end
    items
  end

  def self.scrape_bb_commods
    Util.p "screping commods"
    page =  Nokogiri::HTML open(BLOOMBERG_COMMODS_URL)
    items = Hash.new
    data_rows = page.css("tr")
    data_rows.each do |row|
      row_array = row.text.split("\n")
      row_array = row_array.map {|item| item.strip}
      row_array.delete ""
      #Util.p row_array.inspect
      label = row_array.shift.split[0]
      items[label] =  row_array
    end
    items
  end
end



#<div id="futures_data_table">
# <table class="dual_border_data_table">
#   <tbody>
#<tr class="data_header">
#<th class="name">Futures Index</th>
#      <th class="value">Value</th>
#<th class="percent_change">% Change</th>
#      <th class="open_value">Open</th>
#<th class="high">High</th>
#      <th class="low">Low</th>
#<th class="time">Time</th>
#    </tr>
#<tr class="section_header">
#<th class="header_link" colspan="7">Americas Futures</th>
#            </tr>
#<tr>
  #<td class="name">DJIA INDEX FUTURE Sep12</td>
#          <td class="value">12,895.00</td>
#<td class="percent_change up">+0.50%</td>
#          <td class="open_value">12,869.00</td>
#<td class="high">12,895.00</td>
#          <td class="low">12,818.00</td>
#<td class="time">04:11:54</td>
#        </tr>
