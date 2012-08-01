#dependency: something with JSON.stringify
root = window ? global
root.offline = null
@_m ?= {}

_m.delProp = (obj, prop) ->
  return null if !obj
  objProp = obj[prop]
  delete obj[prop]
  objProp

_m.strEqual = (a, b) ->
  return true if a is null and b is null
  return false if a is null or b is null
  a.toString() == b.toString()

_m.capitalize = (string) ->
  "#{string.charAt(0).toUpperCase()}#{string.substring(1)}"

_m.isBlank = (string) ->
  !string or string.length==0

$flags = new Object()

$rootPage = null
$pageAliases = null

execFn = (fnName, context, args...) ->
	namespaces = fnName.split "."
	func = namespaces.pop()
	return if (!func)   
	for ns in namespaces
		context = context[ns]
	context[func].apply(this, args)

#flags can be array or spaced string
setFlags = (flags) ->
    flags = flags.split(" ") if _.isString(flags)
    for flag in flags
        setFlag(flag, true)
WAIT_FLAG = "waitx-flag"
setFlag = (key, val) ->
    $flags[key] = if val? then val else true

consumeFlag = (key) ->
    val = $flags[key]
    $flags[key] = null
    val

viewFlag = (flag) -> $flags[flag]

jsonToParamStr = (obj) ->
    return "" if not obj
    params = for key, val of obj
        "#{key}=#{val}"
    params.join("&")


url = (server, route, paramHash) ->
    urlStr = "#{server}/#{route}"
    urlStr += ("?#{recToParams(paramHash)}" ) if (paramHash)
    return urlStr

#if val = null, assume don't need closing like <br/>
#if want closing tag w/out val, use val= ""
elem = (tag, val, attrs) ->
    open = "<#{tag} #{attrStr(attrs)} #{if !val? then '/' else ''}>"
    open + (if val? then "#{val}</#{tag}>" else "")


link_to = (label, path, attrs) ->
    attrs = attrs || (new Object())
    attrs.href = path
    return elem("a", label, attrs)

#arguments is not a real array so can't use array methods like join

objKey = (prefix, id) ->    return prefix+id


#cacheObj = (key, obj) ->    cache(key, JSON.stringify(obj))
#retrieveObj = (key) ->
#    obj = retrieve(key)
#    if obj then JSON.parse(obj) else null
#
#
#cache = (key, val) ->    localStorage[key] = val
#retrieve = (key) ->    return localStorage[key]


isOffline =  ->
    !navigator.onLine

#will have problems if & in a param val
paramStrToJSON = (paramStr) ->
    return "" if !paramStr
    obj = {};
    paramStr.replace(
        new RegExp("([^?=&]+)=([^&]*)?", "g"), ($0, prop, val)->obj[prop] = val
    )
    obj

multiline = (string) ->
    return "" if (!string)
    while (string.indexOf("\n") > -1)
        string = string.replace("\n", "<br/>")
    string

numEqual = (a,b) ->  a*1 == b*1



###
FORM_EXCLUDED_PROPS = ["utf8", "authenticity_token"]

checkCBs = (cboxes, checked) ->
    #log "checkCBs(sel, #sel, check)", cboxes, $(cboxes).length, checked

checkbox = (checked, attrs) ->
    attrs.type = "checkbox"
    attrs.checked= "checked" if checked
    elem("input", null, attrs)



###