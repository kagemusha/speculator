# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


COAL_HEADERS = ["Week to", "C Appl", "N App", "Ill Bas", "Pow Riv", "Uinta"]
STATUS_SEL = "#last_update"
window.initHomePg = ->
  log "initHomePg"
  loadDataPanel()

loadDataPanel = ->
  $(STATUS_SEL).html "Loading datax..."
  $('#data_panel').load 'mkt_data', ->
    log "replacing coal headers"
    footerArray = new Array()
    $(".simpletable th").each  ->
      footerArray.push "&nbsp&nbsp&nbsp"+$(@).text().replace /s*\ns*/g, " "
      $(@).text COAL_HEADERS.shift()
    footerArray.shift() #get rid of first header
    $('#data_panel').append footerArray.join("<br>")
    sortIndexRowsByLatest()
    correctCoalRows()
    $(STATUS_SEL).html "Last loaded #{new Date()}"
    setTimeout initHomePg, 600*1000

INDEX_TBL_SEL = "table.mkt_data#indexes"
INDEX_TBL_ROW_SEL = "#{INDEX_TBL_SEL} tr[class!='head']"
sortIndexRowsByLatest = ->
  log "sortIndexRows", $(INDEX_TBL_ROW_SEL).length
  $("#{INDEX_TBL_SEL} tbody").append $(INDEX_TBL_ROW_SEL).get().sort (t1,t2)->
    time1 = $(t1).find("td:nth-child(7)").text()
    time2 = $(t2).find("td:nth-child(7)").text()
    markTime(time2) > markTime(time1)

markTime = (time) -> (if time.indexOf(":") > -1 then "b" else "a") + time



#  rows.each ->
#    log "index", $(this).find("td:nth-child(7)").text()

  #  .append($("tr").get().sort (a, b) ->
  #    $(a).children("td")parseInt($(a).attr("class").match(/\d+/)) - parseInt($(b).attr("class").match(/\d+/))
  #  )

correctCoalRows = ->
  $(".simpletable tr[align='left']").remove()
  $(".simpletable tr").each (i)  ->
    $(this).addClass "data" if i > 2
    while $(this).children().length > 6
      $(this).after("<tr class='addedRow'></tr>")
      $(".simpletable tr.addedRow").append $(this).children().slice(6, 12)
      $(".simpletable tr.addedRow").removeClass("addedRow")
  $(".simpletable").append($(".simpletable tr.data").get().reverse())

