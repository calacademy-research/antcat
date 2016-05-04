module MarkdownHelper
  def markdown text
    AntcatMarkdown.render text
  end
end
