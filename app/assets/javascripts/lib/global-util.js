var $flags, $pageAliases, $rootPage, WAIT_FLAG, consumeFlag, elem, execFn, isOffline, jsonToParamStr, link_to, log, multiline, numEqual, objKey, paramStrToJSON, root, setFlag, setFlags, strEqual, strValInArray, url, viewFlag;
var __slice = Array.prototype.slice;
root = typeof window !== "undefined" && window !== null ? window : global;
root.offline = null;
$flags = new Object();
$rootPage = null;
$pageAliases = null;
execFn = function() {
    var args, context, fnName, func, namespaces, ns, _i, _len;
    fnName = arguments[0], context = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    namespaces = fnName.split(".");
    func = namespaces.pop();
    if (!func) {
        return;
    }
    for (_i = 0, _len = namespaces.length; _i < _len; _i++) {
        ns = namespaces[_i];
        context = context[ns];
    }
    return context[func].apply(this, args);
};
setFlags = function(flags) {
    var flag, _i, _len, _results;
    if (_.isString(flags)) {
        flags = flags.split(" ");
    }
    _results = [];
    for (_i = 0, _len = flags.length; _i < _len; _i++) {
        flag = flags[_i];
        _results.push(setFlag(flag, true));
    }
    return _results;
};
WAIT_FLAG = "waitx-flag";
setFlag = function(key, val) {
    return $flags[key] = val != null ? val : true;
};
consumeFlag = function(key) {
    var val;
    val = $flags[key];
    $flags[key] = null;
    return val;
};
viewFlag = function(flag) {
    return $flags[flag];
};
jsonToParamStr = function(obj) {
    var key, params, val;
    if (!obj) {
        return "";
    }
    params = (function() {
        var _results;
        _results = [];
        for (key in obj) {
            val = obj[key];
            _results.push("" + key + "=" + val);
        }
        return _results;
    })();
    return params.join("&");
};
url = function(server, route, paramHash) {
    var urlStr;
    urlStr = "" + server + "/" + route;
    if (paramHash) {
        urlStr += "?" + (recToParams(paramHash));
    }
    return urlStr;
};
elem = function(tag, val, attrs) {
    var open;
    open = "<" + tag + " " + (attrStr(attrs)) + " " + (!(val != null) ? '/' : '') + ">";
    return open + (val != null ? "" + val + "</" + tag + ">" : "");
};
link_to = function(label, path, attrs) {
    attrs = attrs || (new Object());
    attrs.href = path;
    return elem("a", label, attrs);
};
log = function() {
    var array, i, msg, _ref;
    try {
        msg = arguments[0];
        if (arguments.length > 1) {
            msg += ": ";
            array = new Array();
            for (i = 1, _ref = arguments.length - 1; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
                array.push(JSON.stringify(arguments[i]));
            }
            msg += array.join(",");
            return console.log(msg);
        } else {
            return console.log(msg);
        }
    } catch (e) {
        return console.log("log fn err: " + e);
    }
};
objKey = function(prefix, id) {
    return prefix + id;
};
isOffline = function() {
    return !navigator.onLine;
};
strValInArray = function(val, array) {
    var aVal, _i, _len;
    if (array === null) {
        return false;
    }
    for (_i = 0, _len = array.length; _i < _len; _i++) {
        aVal = array[_i];
        if (strEqual(val, aVal)) {
            return true;
        }
    }
    return false;
};
paramStrToJSON = function(paramStr) {
    var obj;
    if (!paramStr) {
        return "";
    }
    obj = {};
    paramStr.replace(new RegExp("([^?=&]+)=([^&]*)?", "g"), function($0, prop, val) {
        return obj[prop] = val;
    });
    return obj;
};
multiline = function(string) {
    if (!string) {
        return "";
    }
    while (string.indexOf("\n") > -1) {
        string = string.replace("\n", "<br/>");
    }
    return string;
};
strEqual = function(a, b) {
    return toString(a) === toString(b);
};
numEqual = function(a, b) {
    return a * 1 === b * 1;
};