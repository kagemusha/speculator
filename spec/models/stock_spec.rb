require 'spec_helper'

describe Stock do

  it "should have stocks" do
    stock_count = Stock.all.length
    puts "stock count: #{stock_count}"
    stock_count.should> stock_count
  end

  it "should return all stmts from stmts command" do
    symbol = "msft"
    Stock.where(symbol: symbol).first.fin_stmts.each do |stmt|
      puts "#{stmt.class.name}: #{stmt.period_type}, #{stmt.period_end}, #{stmt.currency}"
    end

  end
end
