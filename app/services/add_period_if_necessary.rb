# frozen_string_literal: true

class AddPeriodIfNecessary
  include Service

  ENDS_WITH_TERMINAL_PUNCTUATION_REGEX = /[.!?]\Z/

  attr_private_initialize :string

  def call
    return "".html_safe if string.blank?
    return string if already_ends_with_terminal_punctuation?

    string + '.'
  end

  private

    def already_ends_with_terminal_punctuation?
      string.match?(ENDS_WITH_TERMINAL_PUNCTUATION_REGEX)
    end
end
