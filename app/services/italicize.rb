# frozen_string_literal: true

class Italicize
  include ActionView::Helpers::TagHelper # For `#tag`.
  include Service

  attr_private_initialize :content

  def call
    tag.i content
  end
end
