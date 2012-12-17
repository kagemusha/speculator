class NotesController < ApplicationController

  def new
    session[:back_from_note] = request.referer
    @stock = Stock.find(params[:stock_id])
    @note = Note.new
  end

  def create
    @note = Note.new(params[:note])
    @note.stock = Stock.find(params[:stock_id])
    respond_to do |format|
      if @note.save
        #todo return to previous page (stock, new lows)
        Util.p "noteID", @note.id
        back =  session.delete :back_from_note
        format.html { redirect_to back, notice: 'Note was successfully created.' }
        format.json { render json: @note, status: :created }
      else
        format.html { render action: "new", notice: 'Not created, try again' }
        #format.json { render json: @opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    get_note(params)
    render :partial=>"notes/show"
  end

  def destroy
    get_note(params)
    title = @note.title
    respond_to do |format|
      if @note.destroy
        Util.p "#{title} destrrroyed"
        format.json { render json: {title: title, success: true } }
      else
        format.json { render json: @note, status: :unprocessable_entity }
      end
    end
  end

  private

  def get_note(params)
    #@note = Notes.find(params[:id]) doesn't work - seems need to access from embedding obj
    @stock = Stock.find(params[:stock_id])
    @note = @stock.notes.find(params[:id])
  end
end
