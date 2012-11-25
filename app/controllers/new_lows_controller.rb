require 'date'

class NewLowsController < ApplicationController

  def index
    if params[:date]
      @date = Date.parse(params[:date])
      @new_lows = NewLow.where :date=>@date
    else
      @dates = (NewLow.each.map {|low| low.date}).uniq
      @date_counts = @dates.map {|date| [date, NewLow.where(date: date).count]}
    end
  end

  def update_all_date
    old_date = Date.parse params[:old_date]
    if params[:new_date].blank?
      count = NewLow.where(date: old_date).length
      render json: {count: count}
    else
      if params[:new_date].length < 8
        render json: {msg: "error must enter at least 8 chars e.g. 20120801"}
        return
      end
      new_date = Date.parse params[:new_date]
      Util.p "new_deet", new_date
      #NewLow.where(date: old_date).update({date: params[:new_date]}) #doesn't work!!
      NewLow.where(date: old_date).each do |nl|
        nl.update_attributes({date: params[:new_date]})
      end
      render json: {msg: "updated"}
    end
  end

  def scrape
    if params[:date]
    end
  end
end
