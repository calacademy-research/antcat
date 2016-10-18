class MarkdownController < ApplicationController
  def preview
    text = params[:text] || "no content"

    markdown = AntcatMarkdown.render text
    render json: markdown
  end
end
