module Formatters::RefactorFormatter
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  # duplicated from Formatters::Formatter
  def italicize string
    content_tag :i, string
  end
end
