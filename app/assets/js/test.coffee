code = '''
  #!/usr/bin/env node
  Sound.prototype = { something; }
  Sound.prototype.play = function() {}
  Sound.prototype.play = myfunc
  Sound.play = function() {}
  var parser = document.createElement('a');
  parser.href = "http://example.com:3000/pathname/?search=test#hash";

  parser.protocol; // => "http:"
  parser.hostname; // => "example.com"
  parser.port;     // => "3000"
  parser.pathname; // => "/pathname/"
  parser.search;   // => "?search=test"
  parser.hash;     // => "#hash"
  parser.host;     // => "example.com:3000"

  // Cross-browser xml parsing
  parseXML: function( data ) {
    var xml, tmp;
    if ( !data || typeof data !== "string" ) {
      return null;
    }
    try {
      if ( window.DOMParser ) { // Standard
        tmp = new DOMParser();
        xml = tmp.parseFromString( data , "text/xml" );
      } else { // IE
        xml = new ActiveXObject( "Microsoft.XMLDOM" );
        xml.async = "false";
        xml.loadXML( data );
      }
    } catch( e ) {
      xml = undefined;
    }
    if ( !xml || !xml.documentElement || xml.getElementsByTagName( "parsererror" ).length ) {
      jQuery.error( "Invalid XML: " + data );
    }
    return xml;
  };
'''

$.get("/files/javascript.tmLanguage").success (data) ->
  window.lang = data
  window.js_lang = plist_to_json(lang)
  console.log js_lang
  console.log  "------------------------------------------------------"
  new_code = []
  for line in code.split("\n")
    for pattern,i in js_lang.patterns
      continue if [13,14,15,16,17,19,31,32,35,37].find(i)
      pattern.match = pattern.match.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g, "&") if pattern.match
      try
        regex = new RegExp(pattern.match, "g")
        match_result = line.match(regex)
        if match_result
          console.log "Line: ", line
          console.log "[#{i}] Name: " , pattern.name
          console.log "REGEX: ", pattern.match
          console.log "RESULT", match_result
          if pattern.captures
            console.log "CAPTURES ===========>", pattern.captures
            line = line.replace regex, (full_match, sub_matches..., position, full_line) ->
              console.log full_match, sub_matches, position, full_line
              line_info = []
              for sub, i in sub_matches
                continue if sub.isBlank()
                scope = {}
                scope.start = full_match.search(RegExp.escape(sub))
                scope.size  = sub.length
                scope.name  = pattern.captures[i+1].name
                scope.text  = sub
                line_info.push scope
              console.log line_info
              total_offset = 0
              close_tag = "</span>"
              for scope in line_info
                open_tag = "<span class='#{scope.name.split(".").join(" ")}'>"
                full_match = full_match.insert(open_tag, scope.start + total_offset)
                total_offset += open_tag.length
                full_match = full_match.insert(close_tag, scope.start + scope.size + total_offset)
                total_offset += close_tag.length
              console.log full_match
              full_match
          else
            line = line.replace(regex, "<span class='#{pattern.name.split(".").join(" ")}'>$&</span>")
      catch err
        console.error "Error parsing regex `#{pattern.name}` #{i}: "

      console.log "--------------------------"
    new_code.push(line)

  $(".preview pre").html(new_code.join("\n")).addClass("source js")


