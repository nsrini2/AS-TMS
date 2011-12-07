jQuery.parseQuery = function(query) {
    var vars = query.split("?");
    if(vars.length < 2) return {}
    var qs = vars[1];
    var pairs = qs.split('&');
    var retval = {}
    for(var i = 0; i < pairs.length; i++){
        var d = pairs[i].split('=');
        if(d.length != 2){ continue; }
        retval[d[0]] = d[1];
    }
    return retval
}