# frozen_string_literal: true

class MarkdownController < ApplicationController
  def preview
    render json: Markdowns::Render[text_with_converted_tags]
  end

  private

    def text_with_converted_tags
      text = params[:text] || ''
      Taxt::ConvertTags[text]
    end
end
