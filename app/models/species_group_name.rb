# coding: UTF-8
class SpeciesGroupName < Name

  def dagger_html
    Formatters::Formatter.italicize super
  end

end

