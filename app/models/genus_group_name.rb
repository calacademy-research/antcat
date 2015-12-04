# coding: UTF-8
class GenusGroupName < Name
  include Formatters::LinkFormatter

  def dagger_html
    italicize super
  end

end