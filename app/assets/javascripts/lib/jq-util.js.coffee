#very useful for dynamic pages or when
@_m ?= {}

window.refreshPage = (page) ->
  try
    $(idSel page).page('destroy').page()
  catch e


window.idSel = (id) ->
  return "" if !id or id.length == 0
  if (id[0]=="#") then id else "##{id}"

window.idUnsel = (id) ->
  return "" if !id or id.length == 0
  if (id[0]!="#") then id else id.substr(1)

window.verifySel = (sel) ->
  console.log "len #{sel}: #{$(sel).length}"

_m.getInput = (source, containerType=".form") ->
  container = $(source).closest(containerType)
  inputs = $(container).find FORM_DATA_FIELDS_SEL
  log "getInp", source, containerType, $(container).attr("id"), $(inputs).length
  vals = _m.getInputVals inputs
  arrayedVals(vals)

window.arrayedVals = (vals) ->
  for own key, val of vals
    matches = key.match /(.*)\[[\d+]\]/
    if matches
      arrayProp = matches[1]
      vals[arrayProp] ?= new Array()
      vals[arrayProp].push _m.delProp vals,key
  vals

window.getObjFromForm = (formId) ->
  inputs = window.formDataFields formId
  _m.getInputVals(inputs)


_m.getInputVals = (inputs) ->
  obj = new Object()
  for input in inputs
    prop = $(input).attr "name"
    val = $(input).attr "value"
    #log "input name, value", prop, val
    try
      if $(input).is(':radio')
        #log "radio", $(input).attr('checked'), $(input).is(':checked')
        obj[prop] = val if $(input).is(':checked')
      else if $(input).is(':checkbox')
        if $(input).is(':checked')
          if obj[prop]? then obj[prop].push(val) else obj[prop] = [val]
      else if $(input).is(':submit')
        log "no submit!!"
      else
        obj[prop] = val
      #log "obj[prop]", prop, obj[prop]
    catch e
      log e
  delete obj.submit
  obj

FORM_DATA_FIELDS_SEL = "*:input:not(:button,:reset,:submit,:image)"
window.formDataFields = (formId) ->
  sel = "#{jqm.idSel formId} #{FORM_DATA_FIELDS_SEL} "
  $(sel)


window.populateForm = (formId, obj) ->
  formId = idSel formId
  $("#{formId} :input:not(:button,:reset,:submit,:image,:checkbox,:radio)").attr("value", "")
  checkCBs $("#{formId} :checkbox"), false
  checkCBs $("#{formId} :radio"), false
  #log "hidden submits", $("#{formId} :input:hidden:submit").length
  $("#{formId} :input:hidden:submit").remove()

  for prop, val of obj
    inputFields = $("#{formId} :input[name='#{prop}']:not(:button,:reset,:submit,:image)")
    for input in inputFields
      if $(input).is(':radio')
        check = equalStr( $(input).attr("value"), val )
        #log $(input).attr("name"), check
        checkCBs(input, true) if check
      else if $(input).is(':checkbox')
        #log $(input).attr("name"), val, $(input).attr("value"), valInArray( $(input).attr("value"), val )
        checkCBs input, valInArray( $(input).attr("value"), val )
      else
        $(input).attr "value", val

_m.formCallback = (submit, callback, form="form") ->
  $(submit).live "click", ->
    log "formCB", form, submit
    log "formcb cb", callback
    params = _m.getInput $(this), form
    log "formCBParams", params
    callback(params)
    false


_m.submitData = (data={}) ->
  data.utf8 = "✓"
  data.remote="true"
  data

_m.AUTH_TOKEN_KEY = "_m-auth-tok_key"
_m.authTokenOnPage = ->
  $('meta[name="csrf-token"]').attr('content')
#this seems to work for login, register etc. but not once logged in
_m.authToken = ->
  localStorage[_m.AUTH_TOKEN_KEY] || _m.authTokenOnPage()


_m.jsonPost = (url, data, success, error=_m.postError) ->
  if _.isFunction(data)
    success = data
    data = {}
  data = _m.submitData data
  #log "authtoken", authToken
  $.ajax
    url: url
    type: 'POST'
    dataType: 'json'
    data: data
    headers:
      'X-CSRF-Token': _m.authToken()
    success: success
    error: error

_m.postError = (jqXHR, textStatus, errorThrown) ->
  log "postError", errorThrown

_m.showHide = (showSel, hideSel) ->
  $(showSel).show()
  $(hideSel).hide()
