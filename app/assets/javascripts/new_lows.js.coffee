# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
STOCK_SUMMARY_PANEL = ".stock"
stock_headline_panel_id = (symbol) -> "##{symbol}.stock_headline"
stock_full_panel_id = (symbol) -> "##{symbol}.stock_panel"
stock_desc_field = (symbol) -> $(".stock_panel##{symbol} .company_desc .desc")

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
  $("a.collapse_stock_desc").live "click", ->
    symbol=$(this).attr "symbol"
    desc = stock_desc_field(symbol).attr "desc"
    $("a.collapse_stock_desc").hide()
    $("a.exp_stock_desc").show()
    stock_desc_field(symbol).html desc[0..90]
  $("a.exp_stock_desc").live "click", ->
    symbol=$(this).attr "symbol"
    desc = stock_desc_field(symbol).attr "desc"
    $("a.collapse_stock_desc").show()
    $("a.exp_stock_desc").hide()
    stock_desc_field(symbol).html desc




showStockHeadline = (symbol, show=true) ->
  [showFn, hideFn] = if show then [stock_headline_panel_id, stock_full_panel_id] else [stock_full_panel_id, stock_headline_panel_id]
  $(showFn(symbol)).show()
  $(hideFn(symbol)).hide()