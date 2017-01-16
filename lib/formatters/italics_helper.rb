# Used in controllers/models.
# TODO move to `Name` after removing from controllers,
# and keep the duplicated copy in `ApplicationHelper` totally separate.

module Formatters::ItalicsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def italicize string
    content_tag :i, string
  end
end
