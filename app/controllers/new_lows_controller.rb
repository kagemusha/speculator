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

  def scrape
    if params[:date]
    end
  end
end
