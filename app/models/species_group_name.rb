# coding: UTF-8
class SpeciesGroupName < Name

  def dagger_html
    Formatters::Formatter.italicize super
  end

  def epithet_count
    name.split(' ').size - 1
  end

end

