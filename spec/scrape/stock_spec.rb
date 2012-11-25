require 'spec_helper'


#@SYMBOL = "msft"
#@DOC = "http://quotes.wsj.com/#{@SYMBOL}/financials/quarter/income-statement"
#puts "hello"
#doc = Nokogiri::HTML( open @DOC )
#tables = Array.new
#doc.search('table').each do|tbl|
#  #scrape
#end

QTR_TYPE = FinancialStatement::Q
ANNUAL_TYPE = FinancialStatement::A
PERIOD_TYPES =[QTR_TYPE,ANNUAL_TYPE]
VALID_UNITS = ["Thousands","Millions","Billions"]

SYMBOLS = ["msft","hpq","amd"]
VALIDATION_SETS = {
    "msft"=>{:fy=>"June",:currency=>"USD", "mult"=>1},
    "hpq"=>{:fy=>"October",:currency=>"USD", "mult"=>1},
    "amd"=>{:fy=>"December",:currency=>"USD", "mult"=>1, "mult_cf_q"=>0.001},
    "arc"=>{:fy=>"December",:currency=>"USD", "mult"=>0.001}
}
SYMBOLS = ["msft","hpq","amd"]

#,#,#

def test_statements(symbol, &test)
  specs = [WsjDataMappings::BS_SPECS, WsjDataMappings::PL_SPECS, WsjDataMappings::CF_SPECS]
  specs.each do |spec|
    PERIOD_TYPES.each do|period_type|
      url = WsjDataMappings.financials_url(symbol, spec[:url_frag], period_type)
      puts "url #{url}"
      page = Nokogiri::HTML(open url)
      tables = TableScraper.page_tables_to_arrays(page, "table.#{WsjDataMappings::TABLE_CLASS}")
      test.call VALIDATION_SETS[symbol], spec, period_type, tables
    end
  end
end

def test_get_stmt_params(validation_set, spec, period_type, tables)
  #puts "tables[0]: #{tables[0].inspect}"
  params_cell = tables[0][0] #header row of first table as array
  periods,fiscal_yr,currency,units = StockScrape.get_stmt_params period_type, params_cell
  #puts "periods,etc: #{periods.inspect}, #{fiscal_yr}, #{currency}, #{units}"
  periods.length.should==5
  fiscal_yr.should==validation_set[:fy]
  currency.should==validation_set[:currency]
  stmt_specific_mult = "mult_#{spec[:abbr]}_#{period_type}"
  valid_mult = validation_set[stmt_specific_mult]|| validation_set["mult"] || 1
  puts "mult_key: #{stmt_specific_mult}, #{valid_mult}"
  WsjDataMappings.multiplier(units).should==valid_mult
  VALID_UNITS.should include(units)
end

def stmt_test(stmt_specs, symbols)
  symbols.each do |symbol|
    PERIOD_TYPES.each do |period_type|
      StockScrape.get_financial_statement_data(symbol, stmt_specs, period_type)
    end
  end
end


describe Stock do

  before(:each) do

  end


  #it "should generate correct WSJ url" do
  #  symbol = "msft"
  #  spec = WsjDataMappings::BS_SPECS
  #  url = WsjDataMappings.financials_url(symbol, spec[:url_frag], ANNUAL_TYPE)
  #  url.should=="http://quotes.wsj.com/msft/financials/annual/balance-sheet"
  #end
  ##http://quotes.wsj.com/MSFT/financials/annual/balance-sheet
  ##http://quotes.wsj.com/MSFT/financials/quarter/balance-sheet
  ##http://quotes.wsj.com/MSFT/financials/annual/cash-flow
  ##http://quotes.wsj.com/MSFT/financials/annual/income-statement

    #DATES=[["January",1,31],["June",6,30],["December",12,31] ]
  #it "should get last day of period correctly" do
  #  DATES.each do |date|
  #    valid_date = Date.new(2012, date[1], date[2])
  #    puts "valid_date: #{valid_date}"
  #    StockScrape.last_day_of_fiscal_year("2012", date[0]).should==valid_date
  #  end
  #end

  #it "should return nil if no page given"  do
  #  #pending "add some examples to (or delete) #{__FILE__}"
  #  TableScraper.page_tables_to_arrays(nil).should==nil
  #end
  #


  #it "should get approp num tables on each WSJ fin stmts page" do
  #  test_statements(validation_data) { |spec, period_type, tables| tables.length.should==spec[:table_count] }
  #end

  it "should get correct statement params from stmt page" do
    symbols = ["msft","arc","amd"]
    symbols.each do |symbol|
      test_statements(symbol) { |validation_set, spec, period_type, tables| test_get_stmt_params(validation_set, spec, period_type, tables) }
    end
  end

  #it "should get correct bal sheet data from wsj" do
  #  stmt_specs = WsjDataMappings::BS_SPECS
  #  symbols = ["msft","hpq","amd"]
  #  stmt_test(stmt_specs, symbols)
  #end
  #
  #it "should get correct p/l data from wsj" do
  #  stmt_specs = WsjDataMappings::PL_SPECS
  #  symbols = ["msft","hpq","amd"]
  #  stmt_test(stmt_specs, symbols)
  #end
  #
  #it "should get correct cash flow data from wsj" do
  #  stmt_specs = WsjDataMappings::BS_SPECS
  #  symbols = ["msft"] #,"hpq","amd"]
  #  stmt_test(stmt_specs, symbols)
  #end



end
