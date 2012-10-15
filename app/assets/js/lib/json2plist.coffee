window.json2plist = (json) ->
  header  = '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n'
  footer  = '</dict>\n</plist>\n'
  content = ""
  indent_level = 1

  plist_object2string = (obj, oindent) ->
    obj_str = ""
    for own okey,ovalue of obj
      continue if okey == "$$hashKey"
      obj_str += "#{'\t'.repeat(oindent)}<key>#{okey}</key>\n"
      switch typeof ovalue
        when "string"
          obj_str += "#{'\t'.repeat(oindent)}<string>#{ovalue}</string>\n"
        when "object"
          if Array.isArray(ovalue)
            obj_str += "#{'\t'.repeat(oindent)}<array>\n#{plist_array2string(ovalue, oindent + 1)}#{'\t'.repeat(oindent)}</array>\n"
          else
            obj_str += "#{'\t'.repeat(oindent)}<dict>\n#{plist_object2string(ovalue, oindent + 1)}#{'\t'.repeat(oindent)}</dict>\n"
    obj_str

  plist_array2string = (array, aindent) ->
    arr_str = ""
    for item in array
      arr_str += "#{'\t'.repeat(aindent)}<dict>\n#{plist_object2string(item, aindent + 1)}#{'\t'.repeat(aindent)}</dict>\n"
    arr_str

  for own key,value of json
    content += "#{'\t'.repeat(indent_level)}<key>#{key}</key>\n"
    switch typeof value
      when "string"
        content += "#{'\t'.repeat(indent_level)}<string>#{value}</string>\n"
      when "object"
        if Array.isArray(value)
          content += "#{'\t'.repeat(indent_level)}<array>\n#{plist_array2string(value, indent_level+1)}#{'\t'.repeat(indent_level)}</array>\n"
        else
          content += "#{'\t'.repeat(indent_level)}<dict>\n#{plist_object2string(value, indent_level+1)}#{'\t'.repeat(indent_level)}</dict>\n"

  header + content + footer