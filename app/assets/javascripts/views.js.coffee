@views ?= {}

views.opinionTmpl = (opinion) ->
  log "opiniontmpl", opinion
  _m.haHtml """
    #{_m.haTag "div", {class: "show_opinion", id: opinion.stock_id} }
      %stock #{opinion.symbol}
      %br
      %lbl Killer:
      %br
      #{opinion.killer}
      %br
      %lbl Sales:
      %br
      #{opinion.sales_comments}
      %br
      %lbl Income:
      %br
      #{opinion.pl_comments}
      %br
      %lbl Balance Sheet:
      %br
      #{opinion.bs_comments}
      %br
      %lbl Cash Flow:
      %br
      #{opinion.cf_comments}
      %br
      %lbl Credit Rating:
      %br
      #{opinion.credit_rating}
      %br
      %lbl General Comments:
      %br
      #{opinion.general_comments}
      %br
      %lbl Action:&nbsp;
      %span.action #{opinion.action}
      %br
      #{views.link "Update", "#", {class: "editOpinion btn", opinion_id: opinion._id, stock_id: opinion.stock_id}}
    """

views.link = (label="<blank>", href="#", options={}, reverse=false) ->
  options["href"] = href
  if reverse
    if (!href or href="#") then options["data-direction"]='reverse' else options["data-rel"]='back'
  _m.haTag "a", options, label
