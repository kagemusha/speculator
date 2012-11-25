# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
window.initOpinionsPg = ->
  log "initOpinionsPg"
  $("#opinions_table").dataTable(
    "aaSorting": [[ 2, "desc" ]]
    "aoColumnDefs": [
      { "sWidth": "80px" }
      { "sWidth": "40px" }
      { "sWidth": "80px" }
      { "sWidth": "400px" }
    ]
    "bPaginate": false,
    "bLengthChange": false,
    "bFilter": true,
    "bSort": true,
    "bInfo": false,
    "bAutoWidth": false
  )


