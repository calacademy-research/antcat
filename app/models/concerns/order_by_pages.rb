# frozen_string_literal: true

# NOTE: This will only be for `Citation`s once that is the only way to cite references [grep:unify_citations].
module OrderByPages
  extend ActiveSupport::Concern

  included do
    # NOTE: Good enough for now (MySQL 5). It does not handle Roman numerals or other complicated formats.
    scope :order_by_pages, -> { order(Arel.sql("CAST(pages AS UNSIGNED), pages")) }
  end
end
