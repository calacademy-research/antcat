# frozen_string_literal: true

class Italicize
  include ActionView::Helpers::TagHelper # For `#content_tag`.
  include Service

  attr_private_initialize :content

  def call
    content_tag :i, content
  end
end
