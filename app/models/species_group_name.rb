# coding: UTF-8
class SpeciesGroupName < Name

  def genus_epithet
    words[0]
  end

  def dagger_html
    Formatters::Formatter.italicize super
  end

  def epithet_count
    name.split(' ').size - 1
  end

end

