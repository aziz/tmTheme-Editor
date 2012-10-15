// https://github.com/sandofsky/plist-to-json

plist_to_json = function(plist) {
  // This method is taken from w3schools
  // http://www.w3schools.com/Dom/dom_loadxmldoc.asp
  var loadXMLString = function(txt)
  {
  try //Internet Explorer
    {
    xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async="false";
    xmlDoc.loadXML(txt);
    return(xmlDoc);
    }
  catch(e)
    {
    try //Firefox, Mozilla, Opera, etc.
      {
      parser=new DOMParser();
      xmlDoc=parser.parseFromString(txt,"text/xml");
      return(xmlDoc);
      }
    catch(e) {alert(e.message)};
    }
  return(null);
  };

  var output = {};
  function jsonify(tag){
    switch(tag.nodeName){
      case 'dict':
        var d = {}
        var nodes = tag.childNodes
        for(var i = 0; i < nodes.length; i++){
          if (nodes[i].nodeName == 'key'){
            var key = nodes[i].textContent
            i++
            while (nodes[i].nodeName == "#text")
              i++
            d[key] = jsonify(nodes[i])
          }
        }
        return d
      break
      case 'array':
        var a = []
        var nodes = tag.childNodes
        for(var i = 0; i < nodes.length; i++){
          if (nodes[i].nodeName != "#text")
            a.push(jsonify(nodes[i]))
        }
        return a
      break

      case 'string':
        return tag.textContent
      break
      case 'data':
        return tag.textContent
      break
      case 'real':
        return tag.textContent
      break
      case 'integer':
        return tag.textContent
      break
      case 'true':
        return true
      break
      case 'false':
        return false
      break
    }
  }
  PLIST = plist
  var doc = loadXMLString(plist)
  DOC = doc
  for(var i = 0; i < doc.documentElement.childNodes.length ; i++){
    if (doc.documentElement.childNodes[i].nodeName != "#text")
      return jsonify(doc.documentElement.childNodes[i])
  }

}