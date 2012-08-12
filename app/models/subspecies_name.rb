class SubspeciesName < SpeciesGroupName

  def self.get_name data
    data[:subspecies]
  end

  def self.make_import_attributes _, data
    attributes = {epithets: '', html_epithets: ''.html_safe}
    for subspecies in data[:subspecies]
      # use the specified subspecies epithet for the last component
      # this is in case it has a different gender ending than the epithet
      # in the protonym
      if data[:subspecies_epithet] && subspecies == data[:subspecies].last
        epithet = data[:subspecies_epithet]
      else
        epithet = subspecies[:species_group_epithet] || subspecies[:subspecies_epithet]
      end
      type = subspecies[:type]
      if type
        attributes[:epithets]      << type << ' '
        attributes[:html_epithets] << type << ' '
      end
      html_epithet = Formatters::Formatter.italicize epithet
      attributes[:epithets]      << "#{epithet} "
      attributes[:html_epithets] << html_epithet << ' '

      attributes[:epithet]       = epithet
      attributes[:html_epithet]  = html_epithet
    end

    attributes[:epithets].strip!
    attributes[:html_epithets].strip!

    parent_name = get_parent_name data
    attributes[:name]          = "#{parent_name} #{attributes[:epithets]}"
    attributes[:html_name]     = parent_name.to_html + ' ' + attributes[:html_epithets]
    attributes[:epithets]      = "#{parent_name.epithet} #{attributes[:epithets]}"
    attributes[:html_epithets] = "#{parent_name.html_epithet} #{attributes[:html_epithets]}"
    attributes
  end

  def self.get_parent_name data
    data[:species] ? data[:species].name : SpeciesName.import_data(data)
  end

end
