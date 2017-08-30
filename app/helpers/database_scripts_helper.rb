module DatabaseScriptsHelper
  def highlight_ruby code
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::Ruby.new
    formatter.format(lexer.lex(code)).html_safe
  end
end
