class Unitalicize
  include Service

  def initialize string
    @string = string.dup
  end

  def call
    raise "Can't unitalicize an unsafe string" unless string.html_safe?
    string.gsub!('<i>', '')
    string.gsub!('</i>', '')
    string.html_safe
  end

  private

    attr_reader :string
end
