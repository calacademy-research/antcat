# coding: UTF-8
class GenusGroupName < Name
  include Formatters::RefactorFormatter

  def dagger_html
    italicize super
  end

end
