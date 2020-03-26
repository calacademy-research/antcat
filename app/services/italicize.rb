# frozen_string_literal: true

class Italicize
  include ActionView::Helpers::TagHelper # For `#content_tag`.
  include Service

  def initialize content
    @content = content
  end

  def call
    content_tag :i, content
  end

  private

    attr_reader :content
end
