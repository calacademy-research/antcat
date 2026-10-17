# frozen_string_literal: true

class MarkdownController < ApplicationController
  MAX_TEXT_LENGTH = 100_000

  # Only used by editing forms (all need a signed-in user).
  before_action :authenticate_user!
  rate_limit to: 120, within: 1.minute, by: -> { current_user.id }, with: -> { head :too_many_requests }

  def preview
    return head :content_too_large if params[:text].to_s.length > MAX_TEXT_LENGTH
    render json: renderer[text_with_converted_tags]
  end

  private

    def renderer
      if params[:format_type_fields] == 'true'
        Types::FormatTypeField
      else
        Markdowns::RenderWithoutWrappingP
      end
    end

    def text_with_converted_tags
      text = params[:text] || ''
      Taxt::ConvertTags[text]
    end
end
