class AddPeriodIfNecessary
  include Service

  def initialize string
    @string = string
  end

  def call
    return "".html_safe if string.blank?
    return string if string[-1..-1] =~ /[.!?]/
    string + '.'
  end

  private

    attr_reader :string
end
