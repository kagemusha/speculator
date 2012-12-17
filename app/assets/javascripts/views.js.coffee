@views ?= {}

views.opinionTmpl = (opinion) ->
  log "opiniontmpl", opinion
  _m.haHtml """
    #{_m.haTag "div", {class: "show_opinion", id: opinion.stock_id} }
      %lbl Date: #{opinion.updated_at.toString('M/d/yyyy')}
      %br
      %lbl Killer:
      %br
      .opinion_field
        #{opinion.killer}
      %br
      %lbl Sales:
      %br
      .opinion_field
        #{opinion.sales_comments}
      %br
      %lbl Income:
      %br
      .opinion_field
        #{opinion.pl_comments}
      %br
      %lbl Balance Sheet:
      %br
      .opinion_field
        #{opinion.bs_comments}
      %br
      %lbl Cash Flow:
      %br
      .opinion_field
        #{opinion.cf_comments}
      %br
      %lbl Hidden Treasure:
      %br
      .opinion_field
        #{opinion.hidden_treasure}
      %br
      %lbl Credit Rating:
      %br
      .opinion_field
        #{opinion.credit_rating}
      %br
      %lbl General Comments:
      %br
      .opinion_field
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
