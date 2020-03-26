# frozen_string_literal: true

class MarkdownController < ApplicationController
  def preview
    text = params[:text] || ''
    render json: Markdowns::Render[text]
  end
end
