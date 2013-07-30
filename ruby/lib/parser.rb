# TODO
# ><& should be escaped
# \\,\n,\t should be escaped
# .replace(/&(?!\w+;)/g, '&amp;')
# .replace(/</g, '&lt;')
# .replace(/>/g, '&gt;');
# bring back the scopebar functionality
# bring textpow inline and improve it

# js: undefined
# coffee:
#  1. arrow in: Application.directive "scopeBar", [], -> and scope.$apply ->
#  2. event in event.target.dataset.entityScope is not green
#  3. is in if popover.is('.slide') should be white
# ruby:
#  1. block variables  |line, index|
#  2. method names after dot are yellow
#  3. HTMLProcessor.new
# css:
#  1. . & # in class and id should get the same color as name
#  2. arial font name is not pinkish
#  3. box-shadow, rgba, border-radius
# html:
#  1. needs escaping
#  2. embedded bg should expand whole line

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