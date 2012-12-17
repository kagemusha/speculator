class LinksController < ApplicationController

  def new
    @stock = Stock.find(params[:stock_id])
    @link = Link.new
  end

  def create
    @link = Link.new(params[:link])
    @link.stock = Stock.find params[:stock_id]
    respond_to do |format|
      if @link.save
        #todo return to previous page (stock, new lows)
        format.html { redirect_to @stock, notice: 'Link was successfully created.' }
        #format.json { render json: @opinion, status: :created, location: @opinion }
      else
        format.html { render action: "new", notice: 'Not created, try again' }
        #format.json { render json: @opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    get_link(params)
    title = @link.title
    respond_to do |format|
      if @link.destroy
        Util.p "#{title} destrrroyed"
        format.json { render json: {title: title, success: true } }
      else
        format.json { render json: @link, status: :unprocessable_entity }
      end
    end
  end

  private

  def get_link(params)
    #@link = Links.find(params[:id]) doesn't work - seems need to access from embedding obj
    @stock = Stock.find(params[:stock_id])
    @link = @stock.links.find(params[:id])
  end



end
