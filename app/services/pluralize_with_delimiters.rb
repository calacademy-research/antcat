# frozen_string_literal: true

class PluralizeWithDelimiters
  include ActionView::Helpers::NumberHelper # For `#number_with_delimiter`.
  include ActionView::Helpers::TextHelper # For `#pluralize`.
  include Service

  def initialize count, singular, plural = nil
    @count = count
    @singular = singular
    @plural = plural
  end

  def call
    pluralize number_with_delimiter(count), singular, plural
  end

  private

    attr_reader :count, :singular, :plural
end
