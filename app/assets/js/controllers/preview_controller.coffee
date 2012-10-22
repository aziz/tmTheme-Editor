Angie.controller "previewController", ['$scope', '$http', '$rootScope'], ($scope, $http, $rootScope) ->

  $scope.current_lang = "javascript"
  $scope.lang_path = "/files/languages/#{$scope.current_lang}.tmLanguage"
  $scope.sample_path = "/files/samples/#{$scope.current_lang}.txt"
  $scope.available_langs = ['javascript', 'coffeescript']

  $scope.plist_lang = null
  $scope.json_lang = null

  $scope.$watch 'lang_path', (n,o) ->
    if $scope.lang_path
      $http.get($scope.lang_path).success (data) ->
        $scope.colorized = ""
        $scope.parsed_code = []
        $scope.scope = []
        $scope.plist_lang = data
        $scope.json_lang = plist_to_json($scope.plist_lang)
        console.log "LANG:", $scope.json_lang
        console.log "MULTI LINES:",  { patterns: $scope.multi_line_patterns() }
        console.log "SINGLE LINES:", { patterns: $scope.single_line_patterns() }
        $http.get($scope.sample_path).success (code) ->
          $scope.code = code
          #$scope.code = "#!/usr/bin/env node"
          $scope.parse()
          #$scope.$apply()

  $scope.set_lang = (lang) ->
    console.log lang
    $scope.current_lang = lang
    $scope.sample_path = "/files/samples/#{lang}.txt"
    $scope.lang_path = "/files/languages/#{lang}.tmLanguage"

  $scope.single_line_patterns = ->
    patterns = $scope.json_lang.patterns.findAll (p)-> !p.begin
    patterns = cleanup(patterns)
    return patterns

  $scope.multi_line_patterns  = ->
    patterns = $scope.json_lang.patterns.findAll (p)->  p.begin
    patterns = cleanup(patterns)
    return patterns

  $scope.parse = ->
    parse_single_line_patterns()
    parse_multi_line_patterns()
    colorize()
    $scope.colorized = $scope.parsed_code.join('\n')

  parse_single_line_patterns = ->
    for line, line_number in $scope.code.split("\n")
      for pattern,i in $scope.single_line_patterns()
        #continue if [27,28,31].find(i)
        $scope.scope[line_number] = [] unless $scope.scope[line_number]
        regex = new RegExp(pattern.match, "g")
        #try
        if pattern.captures
          line = line.replace regex, (full_match, sub_matches..., position, full_line) ->
            # console.log "Full Match: ", full_match
            # console.log "Sub Matched: ", sub_matches
            # console.log "Position: ", position
            scope = {}
            begin_scope = {}
            begin_scope.pos  = position
            begin_scope.size = full_match.length
            begin_scope.name = pattern.name
            begin_scope.text = full_match
            begin_scope.type = "b"
            $scope.scope[line_number].push begin_scope
            end_scope = {}
            end_scope.pos    = begin_scope.pos + full_match.length
            end_scope.size   = full_match.length
            end_scope.name   = pattern.name
            end_scope.text   = full_match
            end_scope.type   = "e"
            $scope.scope[line_number].push end_scope

            for sub, i in sub_matches
              continue unless sub
              continue unless pattern.captures[i+1]
              continue if sub.isBlank()
              begin_scope = {}
              begin_scope.pos  = full_line.search(RegExp.escape(sub))
              begin_scope.size = sub.length
              # console.log pattern
              # console.log line
              # console.log "------------------------------"
              begin_scope.name = pattern.captures[i+1]?.name
              begin_scope.text = sub
              begin_scope.type = "b"
              $scope.scope[line_number].push begin_scope
              end_scope = {}
              end_scope.pos    = begin_scope.pos + sub.length
              end_scope.size   = sub.length
              end_scope.name   = pattern.captures[i+1]?.name
              end_scope.text   = sub
              end_scope.type   = "e"
              $scope.scope[line_number].push end_scope
            'ت'.repeat(full_match.length)
        else
          line = line.replace regex, (full_match, sub_matches..., position, full_line) ->
            # console.log "Full Match: ", full_match
            # console.log "Sub Matched: ", sub_matches
            # console.log "Position: ", position
            if full_match
              # if pattern.lb
              #   console.log sub_matches.compact()
              scope = {}
              begin_scope = {}
              begin_scope.pos  = position
              begin_scope.size = full_match.length
              begin_scope.name = pattern.name
              begin_scope.text = full_match
              begin_scope.type = "b"
              $scope.scope[line_number].push begin_scope
              end_scope = {}
              end_scope.pos    = begin_scope.pos + full_match.length
              end_scope.size   = full_match.length
              end_scope.name   = pattern.name
              end_scope.text   = full_match
              end_scope.type   = "e"
              $scope.scope[line_number].push end_scope
            'ت'.repeat(full_match.length)
        # catch err
        #   console.error "Error parsing regex `#{pattern.name}` #{i}: "
        #console.log $scope.scope[line_number]
        #console.log line
        #console.log "--------------------------"

  parse_multi_line_patterns = ->
    code = $scope.code
    for pattern,i in $scope.multi_line_patterns()
      # 4: has look behinds that are not supported in js
      #continue if [4].find(i)
      #console.log "[#{i}] ", pattern
      regex = new RegExp("(#{pattern.begin})([\\s\\S]+?)(#{pattern.end})", "g")
      code.replace regex, (full_match, sub_matches..., position, full_line) ->
        begin_scope = {}
        begin_scope.line  = code.to(position).split("\n").length - 1
        begin_scope.pos   = code.to(position).split("\n").last().length
        begin_scope.size  = full_match.length
        begin_scope.name  = pattern.name
        begin_scope.text  = full_match
        begin_scope.type  = "b"
        #console.log scope
        $scope.scope[begin_scope.line].push begin_scope
        end_scope = {}
        end_scope.line  = code.to(position + full_match.length).split("\n").length - 1
        end_scope.pos   = code.to(position + full_match.length).split("\n").last().length
        end_scope.size  = full_match.length
        end_scope.name  = pattern.name
        end_scope.text  = full_match
        end_scope.type  = "e"
        #console.log scope
        $scope.scope[end_scope.line].push end_scope

        if begin_scope.line == end_scope.line
          for scope in $scope.scope[begin_scope.line]
            scope.name = pattern.name if scope.pos > begin_scope.pos && scope.pos < end_scope.pos
        else
          begin_scope.line.upto end_scope.line, (line) ->
            if line == begin_scope.line
              for scope in $scope.scope[line]
                scope.name = pattern.name if scope.pos > begin_scope.pos
            else if line == end_scope.line
              for scope in $scope.scope[line]
                scope.name = pattern.name if scope.pos < end_scope.pos
            else
              $scope.scope[line] = []


        full_match

      # if pattern.contentName
      #   cn_regex = new RegExp("(?:#{pattern.begin})([\\s\\S]+?)(?:#{pattern.end})", "g")
      #   code.replace cn_regex, (full_match, sub_matches..., position, full_line) ->
      #     begin_scope = {}
      #     begin_scope.line  = code.to(position).split("\n").length - 1
      #     begin_scope.pos   = code.to(position).split("\n").last().length
      #     begin_scope.size  = full_match.length
      #     begin_scope.name  = pattern.contentName
      #     begin_scope.text  = full_match
      #     begin_scope.type  = "b"
      #     #console.log scope
      #     $scope.scope[begin_scope.line].push begin_scope
      #     end_scope = {}
      #     end_scope.line  = code.to(position + full_match.length).split("\n").length - 1
      #     end_scope.pos   = code.to(position + full_match.length).split("\n").last().length
      #     end_scope.size  = full_match.length
      #     end_scope.name  = pattern.contentName
      #     end_scope.text  = full_match
      #     end_scope.type  = "e"
      #     #console.log scope
      #     $scope.scope[end_scope.line].push end_scope
      #     # Removing all the scopes between begin end end
      #     full_match

      # begin_regex = new RegExp("(#{pattern.begin})(?:[\\s\\S]+?)(?:#{pattern.end})", "g")
      # code.replace begin_regex, (full_match, sub_matches..., position, full_line) ->
      #   #console.log sub_matches
      #   for sub, i in sub_matches
      #     continue if sub.isBlank()
      #     scope = {}
      #     scope.start = full_line.search(RegExp.escape(sub))
      #     scope.size  = sub.length
      #     scope.name  = pattern.beginCaptures[i].name
      #     scope.text  = sub
      #     #console.log scope
      #     $scope.multi_line_scope.push scope
      #   full_match

      # end_regex = new RegExp("(?:#{pattern.begin})(?:[\\s\\S]+?)(#{pattern.end})", "g")
      # code.replace end_regex, (full_match, sub_matches..., position, full_line) ->
      #   #console.log sub_matches
      #   for sub, i in sub_matches
      #     continue if sub.isBlank()
      #     scope = {}
      #     scope.start = full_line.search(RegExp.escape(sub))
      #     scope.size  = sub.length
      #     scope.name  = pattern.endCaptures[i].name
      #     scope.text  = sub
      #     #console.log scope
      #     $scope.multi_line_scope.push scope
      #   full_match

  cleanup = (patterns) ->
    for pattern in patterns
      if pattern.include
        Object.merge(pattern, $scope.json_lang.repository[pattern.include.replace("#","")])

      if pattern.match
        if (/\(\?\<\=(.+?)\)/).test(pattern.match) || (/\(\?\<\!(.+?)\)/).test(pattern.match)
           #console.log pattern.match
           pattern.lb = true
        pattern.match = pattern.match.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g, "&")
                                      .replace(/\(\?\<\=(.+?)\)/, "($1)")
                                      .replace(/\(\?\<\!(.+?)\)/, "([^$1])")
        if pattern.match.match(/\(\?x\)/)
          pattern.match = pattern.match.replace(/\(\?x\)/,'').replace(/\s+/g,'') # TODO: should also remove comments

      if pattern.begin
        if (/\(\?\<\=(.+?)\)/).test(pattern.begin) || (/\(\?\<\!(.+?)\)/).test(pattern.begin)
           pattern.lb_begin = true
        pattern.begin = pattern.begin.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g, "&")
                                      .replace(/\(\?\<\=(.+?)\)/, "(?:$1)")
                                      .replace(/\(\?\<\!(.+?)\)/, "(?:[^$1])")
        if pattern.begin.match(/\(\?x\)/)
          pattern.begin = pattern.begin.replace(/\(\?x\)/,'').replace(/\s+/g,'') # TODO: should also remove comments
        pattern.beginCaptures = [] unless pattern.beginCaptures

      if pattern.end
        if (/\(\?\<\=(.+?)\)/).test(pattern.end) || (/\(\?\<\!(.+?)\)/).test(pattern.end)
           pattern.lb_end = true
        pattern.end = pattern.end.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g, "&")
                                  .replace(/\(\?\<\=(.+?)\)/, "(?:$1)")
                                  .replace(/\(\?\<\!(.+?)\)/, "(?:[^$1])")
        if pattern.end.match(/\(\?x\)/)
          pattern.end = pattern.end.replace(/\(\?x\)/,'').replace(/\s+/g,'') # TODO: should also remove comments
        pattern.endCaptures = [] unless pattern.endCaptures

      if pattern.captures && pattern.begin
         pattern.beginCaptures = pattern.captures
         pattern.endCaptures = pattern.captures

      if pattern.patterns
        for pat in pattern.patterns
          Object.merge(pat, $scope.json_lang.repository[pat.include.replace("#","")]) if pat.include
        cleanup(pattern.patterns)
    return patterns

  sorted_scope = (line_scope) ->
    sorted = line_scope && line_scope.sort (a,b) ->
      if a.pos < b.pos
        return -1
      else if a.pos > b.pos
        return 1
      else # if a.pos == b.pos
        if a.type != b.type && a.type == "e"
          return -1
        else if a.type != b.type && a.type == "b"
          return 1
        else # if a.type == b.type
          if (a.size > b.size && a.type == "b")  || (a.size < b.size && a.type == "e")
            return -1
          else if (a.size > b.size && a.type == "e") || (a.size < b.size && a.type == "b")
            return 1
          else
            console.log "can not determine the order of scopes"
            return 0
    sorted = [] unless sorted
    #console.log "[#{sorted.length}] Sorted uniq scope", sorted
    sorted

  colorize = ->
    for line, line_number in $scope.code.split("\n")
      #console.log line
      scopes = sorted_scope($scope.scope[line_number])
      for scope, i in scopes
        if scope.type == "b"
          tag = "<s class='#{scope.name.split(".").join(" ")}'>"
        else
          tag = "</s>"
        #console.log "TAG:", tag
        line = line.insert(tag, scope.pos)
        j = i
        loop
          j += 1
          scopes[j] && scopes[j].pos = scopes[j].pos + tag.length
          break if j > scopes.length
      #console.log line
      $scope.parsed_code.push("<span class='l l-#{line_number} #{$scope.json_lang.scopeName.split(".").join(" ")}'>#{line}</span>")

