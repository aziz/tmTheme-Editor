Angie.controller "previewController", ['$scope', '$http'], ($scope, $http) ->

  $scope.lang_path = "/files/languages/javascript.tmLanguage"
  $scope.sample_path = "/files/samples/javascript.txt"
  $scope.plist_lang = null
  $scope.json_lang = null
  $scope.parsed_code = []
  $scope.scope = []
  $scope.multi_line_scope = []

  $http.get($scope.lang_path).success (data) ->
    $scope.plist_lang = data
    $scope.json_lang = plist_to_json($scope.plist_lang)
    console.log $scope.json_lang
    console.log "MULTI LINES:",  { patterns: $scope.multi_line_patterns() }
    console.log "SINGLE LINES:", { patterns: $scope.single_line_patterns() }
    $http.get($scope.sample_path).success (code) ->
      $scope.code = code
      $scope.parse()

  cleanup_pattenrs = (patterns) ->
    for pattern in patterns
      if pattern.match && (pattern.match.search(/\(\?\<\=(.+)\)/) or pattern.match.search(/\(\?\<\!(.+)\)/))
         pattern.lb = true
      if pattern.match
         pattern.match = pattern.match.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g, "&")
                                      .replace(/\(\?\<\=(.+?)\)/, "(?:$1)")
                                      .replace(/\(\?\<\!(.+?)\)/, "(?:[^$1])")
      if pattern.begin
         pattern.begin = pattern.begin.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g, "&")
                                      .replace(/\(\?\<\=(.+?)\)/, "(?:$1)")
                                      .replace(/\(\?\<\!(.+?)\)/, "(?:[^$1])")
      if pattern.end
         pattern.end = pattern.end.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g, "&")
                                  .replace(/\(\?\<\=(.+?)\)/, "(?:$1)")
                                  .replace(/\(\?\<\!(.+?)\)/, "(?:[^$1])")
      if pattern.captures
         pattern.beginCaptures = pattern.captures
         pattern.endCaptures = pattern.captures
    return patterns

  $scope.single_line_patterns = ->
    patterns = $scope.json_lang.patterns.findAll (p)-> !p.begin
    patterns = cleanup_pattenrs(patterns)
    return patterns

  $scope.multi_line_patterns  = ->
    patterns = $scope.json_lang.patterns.findAll (p)->  p.begin
    patterns = cleanup_pattenrs(patterns)
    return patterns

  $scope.preview = -> $scope.colorized if $scope.colorized

  $scope.parse = ->
    parse_single_line_patterns()
    console.log "single line scopes", {"scopes": $scope.scope }
    colorize_single_lines()
    parse_multi_line_patterns()
    colorize_multi_lines()
    #$scope.parsed_code = [$scope.code] #TEMP: just to get text to the screen

  parse_multi_line_patterns = ->
    code = $scope.parsed_code.join("\n")
    for pattern,i in $scope.multi_line_patterns()
      # 4: has look behinds that are not supported in js
      continue if [4].find(i)
      #console.log "[#{i}] ", pattern
      regex = new RegExp("(#{pattern.begin})([\\s\\S]+?)(#{pattern.end})", "g")
      code.replace regex, (full_match, sub_matches..., position, full_line) ->
        #console.log full_match, sub_matches, position #, full_line
        #console.log sub_matches
        scope = {}
        scope.start = position
        scope.size  = full_match.length
        scope.name  = pattern.name
        scope.text  = full_match
        #console.log scope
        $scope.multi_line_scope.push scope
        full_match

      if pattern.contentName
        cn_regex = new RegExp("(?:#{pattern.begin})([\\s\\S]+?)(?:#{pattern.end})", "g")
        code.replace cn_regex, (full_match, sub_matches..., position, full_line) ->
          #console.log sub_matches
          scope = {}
          scope.start = position
          scope.size  = full_match.length
          scope.name  = pattern.contentName
          scope.text  = full_match
          #console.log scope
          $scope.multi_line_scope.push scope
          full_match

      begin_regex = new RegExp("(#{pattern.begin})(?:[\\s\\S]+?)(?:#{pattern.end})", "g")
      code.replace begin_regex, (full_match, sub_matches..., position, full_line) ->
        #console.log sub_matches
        for sub, i in sub_matches
          continue if sub.isBlank()
          scope = {}
          scope.start = full_line.search(RegExp.escape(sub))
          scope.size  = sub.length
          scope.name  = pattern.beginCaptures[i].name
          scope.text  = sub
          #console.log scope
          $scope.multi_line_scope.push scope
        full_match

      end_regex = new RegExp("(?:#{pattern.begin})(?:[\\s\\S]+?)(#{pattern.end})", "g")
      code.replace end_regex, (full_match, sub_matches..., position, full_line) ->
        #console.log sub_matches
        for sub, i in sub_matches
          continue if sub.isBlank()
          scope = {}
          scope.start = full_line.search(RegExp.escape(sub))
          scope.size  = sub.length
          scope.name  = pattern.endCaptures[i].name
          scope.text  = sub
          #console.log scope
          $scope.multi_line_scope.push scope
        full_match

  parse_single_line_patterns = ->
    for line, line_number in $scope.code.split("\n")
      for pattern,i in $scope.single_line_patterns()
        regex = new RegExp(pattern.match, "g")
        $scope.scope[line_number] = [] unless $scope.scope[line_number]
        try
          if pattern.captures
            line = line.replace regex, (full_match, sub_matches..., position, full_line) ->
              console.log full_match, sub_matches, position, full_line
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

  colorize_single_lines = ->
    for line, line_number in $scope.code.split("\n")
      #console.log line
      close_tag = "</s>"
      sorted_scope = $scope.scope[line_number] && $scope.scope[line_number].unique().sortBy((s) -> s.start - (s.size/1000))
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
      $scope.parsed_code.push(line)

  colorize_multi_lines = ->
    code = $scope.parsed_code.join("\n")
    # total_offset = 0
    # close_tag = "</s>"
    # sorted_scope = $scope.multi_line_scope && $scope.multi_line_scope.unique().sortBy((s) -> s.start)
    # sorted_scope = [] unless sorted_scope
    # console.log "SORTED: ", {"SORTED_SCOPE": sorted_scope}
    # for scope,i in sorted_scope
    #   open_tag = "<s class='#{scope.name.split(".").join(" ")}'>"
    #   code = code.insert(open_tag,  scope.start)
    #   code = code.insert(close_tag, scope.start + scope.size + open_tag.length)
    #   j = i
    #   loop
    #     j += 1
    #     if sorted_scope[j] && sorted_scope[j].start >= scope.start + scope.size
    #       sorted_scope[j].start = sorted_scope[j].start + open_tag.length + close_tag.length
    #     else
    #       sorted_scope[j].start = sorted_scope[j].start + open_tag.length if sorted_scope[j]
    #     break if j > sorted_scope.length
    $scope.colorized = code