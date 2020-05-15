# frozen_string_literal: true

class AddPeriodIfNecessary
  include Service

  attr_private_initialize :string

  def call
    return "".html_safe if string.blank?
    return string if /[.!?]/.match?(string[-1..])
    string + '.'
  end
end
