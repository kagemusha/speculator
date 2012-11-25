# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
stock_desc_field = (symbol) -> $(".company_desc .desc##{symbol}")

window.initStockPg = ->
  log "initStockPg"
  $("#get_stock_data_btn").live "click", ->
    $("#stock_scrape_status").html "Getting data for #{$("#symbol_field").val()}..."
    getStockInfoFromField()
  $('#symbol_field').bind 'keypress', (ev) ->
    code = if ev.keyCode then ev.keyCode else ev.which
    getStockInfoFromField() if code == 13
  window.initStockPanel()
  pusher = new Pusher '51534d8ca2640c342dba'
  channel = pusher.subscribe 'channel'
  channel.bind 'scrape-symbol-event', (data) ->
    log "scrape event", data.message
    $("#stock_scrape_status").html data.message
    #alert "A scrape event was triggered with message: #{data.message}"



window.initStockPanel = ->
  log "initStockPanel"
  $("a.update_stock").live "click", ->
    log "updaeet stock"
    getStockInfo(this)
  #initScroll()
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

  $(".simple_form.new_opinion").removeAttr("action")
  _m.formCallback ".opinion_submit", submitOpinion, "form"
  opinionFormCB()

submitOpinion = (params) ->
  log "submitOpion", params
  stock_id = params.stock_id
  symbol = params.symbol
  idStr = if params.form_action=="update" then "/#{params.id}" else ""
  log "idStr", idStr
  _m.jsonPost "/opinions#{idStr}", params, (opinion) ->
    log "submitteopinion", opinion
    opinion.stock_id = stock_id
    opinion.symbol = symbol
    _m.refreshTmplById "##{stock_id}.opinion_panel", views.opinionTmpl, opinion

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
  params.recalc = $(initiator).attr "recalc"
  parent = $(initiator).closest(".stock_panel")
  msg = if force then "Rescraping" else "Updating"
  log "stock part params", params
  parent.html "<div class='scraping'>#{msg} <span class='symbol'>#{symbol}</span>...</div>"
  parent.load "/stock_partial", params
  $("#stock_scrape_status").html ""


opinionFormCB = ->
  $(".editOpinion").live "click", ->
    id = $(this).attr "opinion_id"
    log "opid", id
    parent = $(this).closest ".opinion_panel"
    parent.load "/opinions/#{id}/edit"

window.initScroll = ->
  log "initscroll"
  $("input[type='range']").click ->
    symbol = $(this).attr "symbol"
#    verifySel ".stock_section[symbol='#{symbol}']"

  $(":range").rangeinput
    onSlide: (ev, step) =>
      symbol = $(this).attr "symbol"
      verifySel ".stock_section[symbol='#{symbol}']"
      $(".stock_section[symbol='#{symbol}']").css {left: -step}
    progress: true
    value: 100
    change: (e, i) -> scroll.animate {left: -i}, "fast"
    speed: 0