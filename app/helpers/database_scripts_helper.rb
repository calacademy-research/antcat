module DatabaseScriptsHelper
  # TODO extract to a decorator.
  def format_database_script_tags tags
    tags.map do |tag|
      css_class = case tag
                  when "slow"      then "warning-label"
                  when "very-slow" then "warning-label"
                  when "new!"      then "label"
                  else                  "white-label"
                  end

      content_tag :span, class: css_class do
        raw tag.html_safe
      end
    end.join(" ").html_safe
  end

  # TODO extract to a decorator.
  def database_script_github_link script
    master_url = "https://github.com/calacademy-research/antcat/blob/master"
    scripts_path = DatabaseScript::SCRIPTS_DIR
    url = "#{master_url}/#{scripts_path}/#{script.filename_without_extension}.rb"
    link_to "GitHub (dev)", url
  end

  def highlight_ruby code
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::Ruby.new
    formatter.format(lexer.lex(code)).html_safe
  end
end
