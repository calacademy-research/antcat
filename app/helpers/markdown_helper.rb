module MarkdownHelper
  def markdown text
    AntcatMarkdown.render text
  end

  def strip_markdown text
    AntcatMarkdown.strip text
  end
end
