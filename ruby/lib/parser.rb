require 'textpow'
require 'cgi'

class HTMLProcessor

  def  initialize(lang)
    @language = lang
  end

  def start_parsing(scope_name)
    @text= []
  end

  def end_parsing(scope_name)
    if @line
      @compiled += CGI::escapeHTML(@line[@position..-1])
    end
    @text << @compiled
    @text.each_with_index do |line, index|
      @text[index] = "<span class='l l-#{index+1} #{scope_name.gsub('.',' ')}'>#{line}</span>"
    end
    File.open("../../public/files/samples/pre-compiled/#{@language}.html", 'w') do |file|
      file.write(@text.join(""))
    end
  end

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
    @compiled += "<s class='#{tag_name.gsub("."," ")}' data-entity-scope='#{tag_name}'>"
    @position = position
  end

  def close_tag(tag_name, position)
    @compiled += CGI::escapeHTML(@line[@position...position]) if position > @position
    @compiled += "</s>"
    @position = position
  end

end

supported_languages = {
  'coffeescript' => 'coffee',
  'css'          => 'css',
  'html'         => 'html',
  'javascript'   => 'js',
  'python'       => 'python',
  'ruby'         => 'ruby'
}

supported_languages.each do |lang,lang_code|
  print "compiling #{lang}..."
  text = File.read("../../public/files/samples/#{lang}.txt")
  syntax = Textpow.syntax(lang_code)
  syntax.parse(text, HTMLProcessor.new(lang))
  puts "done"
end

