# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
STOCK_SUMMARY_PANEL = ".stock"
stock_headline_panel_id = (symbol) -> "##{symbol}.stock_headline"
stock_full_panel_id = (symbol) -> "##{symbol}.stock_panel"

window.initNewLowsPg = ->
  log "initNewLowsPg"
  $("a.view_stock.showPanel").live "click", ->
    symbol = $(this).attr "symbol"
    dataPanel = $(stock_full_panel_id symbol)
    log "showing panel", symbol
    log "childs#", dataPanel.children().length
    if dataPanel.children().length == 0
      dataPanel.load "/stock_partial", {symbol: symbol}
    #showStockHeadline symbol, false
    $(dataPanel).show()
    $(stock_headline_panel_id symbol).hide()

  $("a.view_stock.hidePanel").live "click", ->
    symbol = $(this).attr "symbol"
    log "hiding panel", symbol
    showStockHeadline symbol
  #$(stock_headline_panel_id symbol).show()
    #$(stock_full_panel_id symbol).hide()
  window.initStockPanel()
  $("#update_new_low_date_btn").live "click", ->
    verifySel "#current_date"
    old_date = $("#current_date").text()
    new_date = $("#update_nl_date").val()
    log "updeet date", old_date, new_date
    _m.jsonPost "/update_new_low_date", {old_date: old_date,new_date: new_date}, (status)->
      log "nldateupdate status", status



showStockHeadline = (symbol, show=true) ->
  [showFn, hideFn] = if show then [stock_headline_panel_id, stock_full_panel_id] else [stock_full_panel_id, stock_headline_panel_id]
  $(showFn(symbol)).show()
  $(hideFn(symbol)).hide()
