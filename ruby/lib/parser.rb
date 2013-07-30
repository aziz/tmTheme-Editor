# TODO
# ><& should be escaped
# \\,\n,\t should be escaped
# .replace(/&(?!\w+;)/g, '&amp;')
# .replace(/</g, '&lt;')
# .replace(/>/g, '&gt;');
# bring back the scopebar functionality
# js: undefined
# ruby: too much yellow
# css: too much yellow, border-radius
# html: bunch of bugs, needs escaping
# css generation out of theme (space means children)

require 'textpow'

class HTMLProcessor

  # called before parsing anything
  def start_parsing(scope_name)
    @line = ""
    @offset = 0
    @text= []
  end

  # called after parsing everything
  def end_parsing(scope_name)
    @text.each_with_index do |line, index|
      @text[index] = "<span class='l l-#{index+1} #{scope_name.gsub('.',' ')}'>#{line}</span>"
    end
    puts @text.join("")
  end

  # called before processing a line
  def new_line(line_content)
    @offset = 0
    @line = line_content.clone
    @text << @line
  end

  def open_tag(tag_name, position_in_current_line)
    tag = "<s class='#{tag_name.gsub("."," ")}'>"
    @line.insert(position_in_current_line + @offset, tag)
    @offset += tag.size
  end

  def close_tag(tag_name, position_in_current_line)
    tag = "</s>"
    @line.insert(position_in_current_line + @offset, tag)
    @offset += tag.size
  end

end

syntax = Textpow.syntax('coffee')
text = File.read("../../public/files/samples/coffeescript.txt")
syntax.parse(text, HTMLProcessor.new)