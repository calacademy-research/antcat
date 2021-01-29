# frozen_string_literal: true

class MarkdownController < ApplicationController
  def preview
    render json: renderer[text_with_converted_tags]
  end

  private

    def renderer
      if params[:format_type_fields] == 'true'
        Types::FormatTypeField
      else
        Markdowns::Render
      end
    end

    def text_with_converted_tags
      text = params[:text] || ''
      Taxt::ConvertTags[text]
    end
end
