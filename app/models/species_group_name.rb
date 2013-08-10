# coding: UTF-8
class SpeciesGroupName < Name
  include Formatters::Formatter

  def genus_epithet
    words[0]
  end

  def species_epithet
    words[1]
  end

  def dagger_html
    italicize super
  end

end

