class Fixes

  def self.rescrape_all
    error_file = File.new("rescrape_errors","a")
    error_file.puts "\n\n**************************"
    error_file.puts "Rescrape #{Time.now}"
    error_file.puts "**************************\n"
    cutoff_time = Time.now - 15.hours
    while (Stock.where(:updated_at => {'$lt' => cutoff_time }).length > 0)
      begin
        Stock.where(:updated_at => {'$lt' => cutoff_time }).order_by("updated_at asc").each do |stock|
          begin
            stock.rescrape
            stock.touch
          rescue Exception=>e
            error_file.puts "Symbol: #{stock.symbol}      #{Time.now}"
            error_file.puts e.message
          end
        end
      rescue
        puts "Cursors!!! Restarting..."
      end
    end
  end

  def self.stock_nums
    Stock.each do |stock|
      stock.fix_float("mkt cap")
    end
  end

  def self.recalc_statements
    Stock.each do |stock|
      stock.balance_sheets.each {|stmt| stmt.recalc()}
      stock.income_statements.each {|stmt| stmt.recalc()}
      stock.cashflow_statements.each do |stmt|
        stmt.recalc()
        stock.fin_calcs.find_or_create_by(period_end: stmt.period_end, period_type: stmt.period_type).recalc()
      end
      stock.save
    end
  end

  def self.make_capex_pos
    Stock.each do |stock|
      p "Stock: #{stock.symbol}"
      stock.cashflow_statements.each do |stmt|
        p "capex: #{stmt.capex}"
        stmt.capex = stmt.capex.abs if stmt.capex
        p "capex fixed: #{stmt.capex}"
      end
      stock.save
    end
  end
  #def self.rescrape_all
  #  Stock.each do |stock|
  #    puts "Rescraping #{stock.symbol}"
  #    stock.update_current_data StockScrape.get_basic_data(stock.symbol)
  #    StockScrape.get_stock_data stock, true
  #  end
  #end


  def self.correct_annual_stmt_dates
    Stock.each do |stock|
      stock.bala
    end
  end


  def self.merge_lowercase_symbols
    Stock.each do |lc_stock|
      if lc_stock.symbol != lc_stock.symbol.upcase
        master = Stock.where(symbol: lc_stock.symbol.upcase).first
        lowers = Stock.where symbol: lc_stock.symbol
        if master
          p "#{lc_stock.symbol} has master:  #{lowers.length}"
          p "  --#{lc_stock.symbol} has opionions:  #{lc_stock.opinions.length}"
          if lc_stock.opinions.length > 0
            lc_stock.opinions.each do |op|
              master.opinions << op
            end
            master.save
            lc_stock.destroy
          end
        else
          p "capitalize #{lc_stock.symbol}"
          lc_stock.symbol = lc_stock.symbol.upcase
          lc_stock.save
        end
      end
    end
  end
end
