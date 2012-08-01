class StocksController < ApplicationController

  def show
    @symbol = params[:symbol]
    @stock = Stock.where(:symbol=>@symbol).first
    StockScrape.get_stock_data(@stock) if !@stock.exch
    Util.p "curdatacur?",@stock.current_data_current?, @stock.current_data
    if @stock.current_data_current?
      @current_data = @stock.current_data
    else
      @current_data = StockScrape.get_basic_data(@stock)
      @stock.update_attribute(:current_data, @current_data)
    end
  end

  def partial
    @symbol = params[:symbol]
    if @symbol.blank?
      render :text=>"Please enter a symbol"
      return
    end
    @symbol.upcase!
    Util.p "stocks/partial", @symbol
    @stock = Stock.where(:symbol=>@symbol).first || StockScrape.scrape_symbol(@symbol)
    StockScrape.get_stock_data(@stock) if !@stock.exch
    Util.p "curdatacur?",@stock.current_data_current?, @stock.current_data
    if @stock.current_data_current?
      @current_data = @stock.current_data
    else
      @current_data = StockScrape.get_basic_data(@stock)
      @stock.update_attribute(:current_data, @current_data)
    end
    StockScrape.get_stock_data(@stock, params[:force]) if params[:update]
    @stock.adjust_units
    render :partial=>"stocks/show", :locals=>{:symbol=>@symbol,:stock=>@stock, :cur_data=>@current_data}
  end

  def fix_units
    @stock = Stock.where(symbol: symbol).first
    return if !@stock
    @stock.adjust_units
    render :partial=>"stocks/show", :locals=>{:symbol=>@stock.symbol,:stock=>@stock, :cur_data=>@stock.current_data}
  end

  def update_data
    @symbol = params[:symbol]
    @stock = Stock.where(:symbol=>@symbol).first
    @stock.update_current_data StockScrape.get_basic_data(@stock.symbol)
    StockScrape.get_stock_data @stock, params[:force]
    render :partial=>"stocks/show", :locals=>{:symbol=>@symbol,:stock=>@stock, :cur_data=>@stock.current_data}
  end
end
