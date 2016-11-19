class MarkdownController < ApplicationController
  def preview
    text = params[:text].presence || "no content"

    markdown = AntcatMarkdown.render text
    render json: markdown
  end

  def formatting_help
    render partial: "shared/markdown_formatting_help"
  end
end
