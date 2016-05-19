class MarkdownController < ApplicationController
  def preview
    text = params[:text] || "no content"

    markdown = AntcatMarkdown.render text
    render json: markdown, content_type: 'text/html'
  end
end
