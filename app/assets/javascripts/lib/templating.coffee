_m.appendTmpl = (containers, templateFn, data, options) ->
  templateFn = eval(templateFn) if typeof templateFn == 'string'
  elems = _m.genElems(templateFn, data, options)
  $(containers).append elems

_m.refreshTmplById = (id, templateFn, data, options) ->
  _m.refreshTmpl "#{idSel id}", templateFn, data, options

_m.refreshTmpl = (containers, templateFn, data, options) ->
  $(containers).empty()
  _m.appendTmpl containers, templateFn, data, options

#refreshTmpl = (containers, templateFn, data, options) ->
#    templateFn = eval(templateFn) if typeof templateFn == 'string'
#    $(containers).empty()
#    elems = genElems(templateFn, data, options)
#    #log "elems", elems
#    $(containers).append elems

_m.genElems = (fn, data, options) ->
  if _.isArray(data)
    elems = for elem in data
              fn elem, options
    if elems then elems.join("") else ""
  else
    fn data, options

