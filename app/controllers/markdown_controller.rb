class MarkdownController < ApplicationController
  def preview
    text = params[:text].presence || ''
    render json: Markdowns::Render[text].html_safe
  end

  def formatting_help
  end
end
