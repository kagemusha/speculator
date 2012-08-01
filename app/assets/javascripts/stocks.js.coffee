# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.initStockPg = ->
  log "initStockPg"
  $("#get_stock_data_btn").live "click", ->
    getStockInfoFromField()
  $('#symbol_field').bind 'keypress', (ev) ->
    code = if ev.keyCode then ev.keyCode else ev.which
    getStockInfoFromField() if code == 13
  window.initStockPanel()


window.initStockPanel = ->
  $("a.update_stock").live "click", ->
    log "updaeet stock"
    getStockInfo(this)

  $(".simple_form.new_opinion").removeAttr("action")
  _m.formCallback ".opinion_submit", submitOpinion, "form"

submitOpinion = (params) ->
  #log "submitOpion", params
  stock_id = params.stock_id
  symbol = params.symbol
  log "stock_id", stock_id
  _m.jsonPost "/opinions", params, (opinion) ->
    log "submitteopinion", opinion
    opinion.stock_id = stock_id
    opinion.symbol = symbol
    _m.refreshTmplById ".opinion_panel##{stock_id}", views.opinionTmpl, opinion

submitOpinionCB = (opinionPartial) ->
  log "submitte opinion"


getStockInfoFromField = ->
  symbol = $("#symbol_field").val()
  log "symbb", symbol
  $(".stock_panel").load "/stock_partial", {symbol: symbol}

getStockInfo = (initiator) ->
  symbol = $(initiator).attr "symbol"
  force = $(initiator).attr("force")=="true"
  params = {symbol: symbol, update: true}
  params.force = true if force
  parent = $(initiator).closest(".stock_panel")
  msg = if force then "Rescraping" else "Updating"
  parent.html "<div class='scraping'>#{msg} <span class='symbol'>#{symbol}</span>...</div>"
  log "getStockInfo pms", params
  log "initiator", $(initiator).attr "class"
  log "parent", if parent then parent else "null"
  parent.load "/stock_partial", params

