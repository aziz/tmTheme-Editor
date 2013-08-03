# TODO
# bring textpow inline and improve it

# js: undefined
# coffee:
#  1. arrow in: Application.directive "scopeBar", [], -> and scope.$apply -> (tmlang bug)
#  2. event in event.target.dataset.entityScope is not green (tmlang bug)
#  3. is in if popover.is('.slide') should be white (tmlang bug)
# ruby:
#  1. block variables  |line, index| (css specefisity issue)
#  2. method names after dot are yellow (tmlang bug)
#  3. HTMLProcessor.new (tmlang bug)
# css:
#  1. . & # in class and id should get the same color as name (css specefisity issue)
#  2. arial font name is not pinkish (css specefisity issue)
#  3. box-shadow, rgba, border-radius
# html:
#  2. embedded bg should expand whole line

require 'textpow'
require "cgi"

class HTMLProcessor

  # called before parsing anything
  def start_parsing(scope_name)
    @text= []
  end

  # called after parsing everything
  def end_parsing(scope_name)
    if @line
      @compiled += CGI::escapeHTML(@line[@position..-1])
    end
    @text << @compiled
    @text.each_with_index do |line, index|
      @text[index] = "<span class='l l-#{index+1} #{scope_name.gsub('.',' ')}'>#{line}</span>"
    end
    # puts @text.join("")
    File.open('../../public/files/samples/pre-compiled/javascript.html', 'w') do |file|
      file.write(@text.join(""))
    end
  end

  # called before processing a line
  def new_line(line_content)
    if @line
      @compiled += CGI::escapeHTML(@line[@position..-1])
    end
    @text << @compiled if @compiled
    @line = line_content.clone
    @compiled = ""
    @position = 0
  end

  def open_tag(tag_name, position)
    @compiled += CGI::escapeHTML(@line[@position...position]) if position > @position
    @compiled += "<s class='#{tag_name.gsub("."," ")}'>"
    # puts "OPEN => POS:  @pos #{@position},  pos: #{position}"
    # puts @compiled
    # puts '-----------------------------'
    @position = position
  end

  def close_tag(tag_name, position)
    @compiled += CGI::escapeHTML(@line[@position...position]) if position > @position
    @compiled += "</s>"
    # puts "END  => POS:  @pos #{@position},  pos: #{position}"
    # puts @compiled
    # puts '-----------------------------'
    @position = position
  end

end

syntax = Textpow.syntax('js')
text = File.read("../../public/files/samples/javascript.txt")
syntax.parse(text, HTMLProcessor.new)