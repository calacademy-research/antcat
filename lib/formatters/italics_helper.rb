module Formatters
  module ItalicsHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Context

    def italicize string
      content_tag :i, string
    end
  end
end
