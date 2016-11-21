class MarkdownController < ApplicationController
  def preview
    text = params[:text].presence || "no content"

    markdown = AntcatMarkdown.render text
    render json: markdown
  end

  def formatting_help
    respond_to do |format|
      format.json { render partial: "formatting_help" }
      format.html { render "formatting_help" }
    end
  end

  def symbols_explanations
    respond_to do |format|
      format.json { render partial: "symbols_explanations" }
    end
  end
end
