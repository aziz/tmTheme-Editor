Angie.controller "previewController", ['$scope', '$http'], ($scope, $http) ->

  $scope.code = '''
    #!/usr/bin/env node
    Sound.play = function() {}
    Sound.prototype = { something; }
    Sound.prototype.play = function() {}
    Sound.prototype.play = myfunc
    var parser = document.createElement('a');
    parser.href = "http://example.com:3000/pathname/?search=test#hash";

    parser.protocol; // => "http:"
    parser.hostname; // => "example.com"
    parser.port;     // => "3000"
    parser.pathname; // => "/pathname/"
    parser.search;   // => "?search=test"
    parser.hash;     // => "#hash"
    parser.host;     // => "example.com:3000"

    /*!
     * jQuery JavaScript Library v1.8.2
     * http://jquery.com/
     *
     * Includes Sizzle.js
     * http://sizzlejs.com/
     *
     * Copyright 2012 jQuery Foundation and other contributors
     * Released under the MIT license
     * http://jquery.org/license
     *
     * Date: Thu Sep 20 2012 21:13:05 GMT-0400 (Eastern Daylight Time)
     */

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



  $scope.lang_path = "/files/javascript.tmLanguage"
  $scope.plist_lang = null
  $scope.json_lang = null
  $scope.scope = []

  $http.get($scope.lang_path).success (data) ->
    $scope.plist_lang = data
    $scope.json_lang = plist_to_json($scope.plist_lang)
    console.log $scope.json_lang
    console.log "MULTI LINES:",  { patterns: $scope.multi_line_patterns() }
    console.log "SINGLE LINES:", { patterns: $scope.single_line_patterns() }
    #console.log "--------------------------"
    $scope.parse()

  $scope.single_line_patterns = -> $scope.json_lang.patterns.findAll (p)-> !p.begin
  $scope.multi_line_patterns  = -> $scope.json_lang.patterns.findAll (p)->  p.begin

  $scope.preview = -> $scope.parsed_code.join("\n") if $scope.parsed_code
  $scope.parse = ->
    $scope.parsed_code = []
    for line, line_number in $scope.code.split("\n")
      for pattern,i in $scope.single_line_patterns()
        # 27, 28, 31: have look behinds that are not supported in js
        continue if [31,27,28].find(i)
        pattern.match = pattern.match.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g, "&") if pattern.match
        #pattern.match = pattern.match.replace(/\(\?<=.+?\)/, "") # TODO: removing lookbehind for now.
        regex = new RegExp(pattern.match, "g")
        $scope.scope[line_number] = [] unless $scope.scope[line_number]
        try
          #match_result = line.match(regex)
          #if match_result
          # console.log "Line: ", line
          # console.log "[#{i}] Name: " , pattern.name
          # console.log "REGEX: ", pattern.match
          # console.log "RESULT", match_result
          if pattern.captures
            #console.log "CAPTURES ==>", pattern.captures
            line = line.replace regex, (full_match, sub_matches..., position, full_line) ->
              #console.log full_match, sub_matches, position, full_line
              for sub, i in sub_matches
                continue if sub.isBlank()
                scope = {}
                scope.start = full_line.search(RegExp.escape(sub))
                scope.size  = sub.length
                scope.name  = pattern.captures[i+1].name
                scope.text  = sub
                $scope.scope[line_number].push scope
              #console.log line_info
              #console.log full_match
              full_match
          else
            line = line.replace regex, (full_match, sub_matches..., position, full_line) ->
              #console.log full_match, sub_matches, position, full_line
              if full_match
                scope = {}
                scope.start = position
                scope.size  = full_match.length
                scope.name  = pattern.name
                scope.text  = full_match
                $scope.scope[line_number].push scope
              full_match
        catch err
          console.error "Error parsing regex `#{pattern.name}` #{i}: "

        #console.log "--------------------------"
    #------------------
    #console.log "SCOPE", {"scope": $scope.scope}
    for line, line_number in $scope.code.split("\n")
      #console.log line
      total_offset = 0
      close_offset = 0
      close_tag = "</s>"
      sorted_scope = $scope.scope[line_number] && $scope.scope[line_number].sortBy((s) -> s.start - (s.size/1000))
      sorted_scope = sorted_scope.unique()
      sorted_scope = [] unless sorted_scope
      #console.log "[#{sorted_scope.length}] Sorted uniq scope", sorted_scope
      for scope, i in sorted_scope
        open_tag = "<s class='#{scope.name.split(".").join(" ")}'>"
        line = line.insert(open_tag,  scope.start)
        line = line.insert(close_tag, scope.start + scope.size + open_tag.length)
        j = i
        loop
          j += 1
          if sorted_scope[j] && sorted_scope[j].start >= scope.start + scope.size
            sorted_scope[j].start = sorted_scope[j].start + open_tag.length + close_tag.length
          else
            sorted_scope[j].start = sorted_scope[j].start + open_tag.length if sorted_scope[j]
          break if j > sorted_scope.length
        #console.log scope
        #console.log line
      #console.log line
      #console.log "====================="
      $scope.parsed_code.push(line)



# <span class='support class js'>Sound.prototype</span>