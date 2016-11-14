module DatabaseScriptsHelper
  def format_database_script_tags tags
    tags.map do |tag|
      css_class = tag == "slow" ? "label" : "white-label"
      content_tag :span, class: css_class do
        raw tag.html_safe
      end
    end.join(" ").html_safe
  end

  def database_script_github_link script
    master_url = "https://github.com/calacademy-research/antcat/blob/master"
    scripts_path = DatabaseScripts::DatabaseScript::SCRIPTS_PATH
    url = "#{master_url}/#{scripts_path}/#{script.filename_without_extension}.rb"
    link_to "GitHub (dev)", url
  end

  def highlight_ruby code
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::Ruby.new
    formatter.format(lexer.lex(code)).html_safe
  end
end
