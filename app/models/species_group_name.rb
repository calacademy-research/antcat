class SpeciesGroupName < Name

  def dagger_html
    Formatters::Formatter.italicize super
  end

end

