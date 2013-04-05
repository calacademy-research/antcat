# coding: UTF-8
class GenusGroupName < Name

  def dagger_html
    Formatters::Formatter.italicize super
  end

end
