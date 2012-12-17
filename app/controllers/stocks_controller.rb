
class StocksController < ApplicationController


  def show
    get_stock_and_symbol(params)
    #handle is !symbol
    StockScrape.get_stock_data(@stock) if !@stock.exch
    Util.p "curdatacur?",@stock.current_data_current?, @stock.current_data
    if @stock.current_data_current?
      @current_data = @stock.current_data
    else
      @current_data = StockScrape.get_basic_data(@stock)
      @stock.update_attribute(:current_data, @current_data)
    end
  end

  def show_partial
    get_stock_and_symbol(params)
    Pusher['channel'].trigger('scrape-symbol-event', {:message => "scrape event for #{@symbol}"})
    if @symbol.blank?
      render :text=>"Please enter a symbol"
      return
    end
    [0..3].each do |i|
      #begin
      if !@stock.exch or params[:update] or params[:force]
        if params[:force]
          @stock.rescrape(true)
        else
          StockScrape.get_stock_data(@stock, false, true)
        end
      end
        #break
      #rescue Timeout::Error => e
      #  Util.p "TIMEOUTEXCEPTION #{i}"
      #  if i==3
      #    render :partial=>"stocks/timeout_error"
      #    return
      #  end
      #rescue Exception => e
      #  if i==3
      #    Util.p "REGEXCEPTION #{i}"
      #    render :partial=>"stocks/timeout_error"
      #    return
      #  end
      #end
    end
    #Util.p "curdatacur?",@stock.current_data_current?, @stock.current_data
    if @stock.current_data_current?
      @current_data = @stock.current_data
    else
      @current_data = StockScrape.get_basic_data(@stock)
      @stock.update_attribute(:current_data, @current_data)
    end
    Util.p "ackt", params[:act]
    #if params[:update]
    #  StockScrape.get_stock_data(@stock, params[:force])
    #end
    if params[:recalc]
      Util.p "recalking"
      @stock.recalc
    end
    #Util.p "stockzz(bs,pl,cf lengths)", @stock.balance_sheets.length, @stock.income_statements.length,
    #        @stock.cashflow_statements.length
    #@stock.balance_sheets.each {|stmt| puts "contr-bs #{stmt.inspect}"}
    render :partial=>"stocks/show", :locals=>{:symbol=>@symbol,:stock=>@stock, :cur_data=>@current_data}
  end

  def fix_units
    @stock = Stock.where(symbol: symbol).first
    return if !@stock
    #@stock.adjust_units
    render :partial=>"stocks/show", :locals=>{:symbol=>@stock.symbol,:stock=>@stock, :cur_data=>@stock.current_data}
  end

  #def update_data
  #  @symbol = params[:symbol]
  #  @stock = Stock.where(:symbol=>@symbol).first
  #  if params[:action] = "recalc"
  #    Util.p "recalking"
  #    @stock.recalc
  #  else
  #    @stock.update_current_data StockScrape.get_basic_data(@stock.symbol)
  #    StockScrape.get_stock_data @stock, params[:force]
  #  end
  #  render :partial=>"stocks/show", :locals=>{:symbol=>@symbol,:stock=>@stock, :cur_data=>@stock.current_data}
  #end

  private

  def get_stock_and_symbol(params)
    @symbol = params[:symbol]
    return if !@symbol
    @symbol.upcase!
    @stock = Stock.where(:symbol=>@symbol).first || StockScrape.scrape_symbol(@symbol)
  end



end
