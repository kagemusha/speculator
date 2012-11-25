namespace :fixes do
  desc "rescrape all"
  task :rescrape_all => :environment do    #without :environment, doesn't load app dir'
    Fixes.rescrape_all
    Util.p "Rescreped all"
  end

  desc "convert floats in stock objects"
  task :convert_floats => :environment do    #without :environment, doesn't load app dir'
    Fixes.stock_nums
    Util.p "Fixed stock nums"
  end

  desc "recalc statements"
  task :recalc_stmts => :environment do    #without :environment, doesn't load app dir'
    Fixes.recalc_statements
    Util.p "Recalced stetments"
  end

  desc "make capex pos"
  task :capex_pos => :environment do    #without :environment, doesn't load app dir'
    Fixes.make_capex_pos
    Util.p "Capex pos"
  end

  desc "merge symbols ci"
  task :merge_stocks => :environment do    #without :environment, doesn't load app dir'
    Fixes.merge_lowercase_symbols
    p "Merged!"
  end

  desc "resrep all"
  task :rescrape_all => :environment do    #without :environment, doesn't load app dir'
    Stock.each do |stock|
      puts "Rescraping #{stock.symbol}"
      stock.update_current_data StockScrape.get_basic_data(stock.symbol)
      StockScrape.get_stock_data stock, true
    end
  end

end