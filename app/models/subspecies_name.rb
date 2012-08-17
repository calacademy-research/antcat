class SubspeciesName < SpeciesGroupName

  def self.get_name data
    data[:subspecies]
  end

  def self.make_import_attributes _, data
    epithets_html = ''.html_safe
    epithets_with_subspecies_types_html = ''.html_safe
    attributes = {epithets: ''}
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
        epithets_with_subspecies_types_html << type << ' '
      end
      epithet_html = Formatters::Formatter.italicize epithet
      attributes[:epithets]               << "#{epithet} "
      epithets_html                       << epithet_html << ' '
      epithets_with_subspecies_types_html << epithet_html << ' '

      attributes[:epithet]       = epithet
      attributes[:epithet_html]  = epithet_html
    end

    attributes[:epithets].strip!
    epithets_html.strip!
    epithets_with_subspecies_types_html.strip!

    parent_name = get_parent_name data
    attributes[:name]          = "#{parent_name} #{attributes[:epithets]}"
    attributes[:name_html]     = parent_name.to_html + ' ' + epithets_html
    attributes[:epithets]      = "#{parent_name.epithet} #{attributes[:epithets]}"
    attributes[:protonym_html] = parent_name.to_html + ' ' + epithets_with_subspecies_types_html
    attributes
  end

  def self.get_parent_name data
    data[:species] ? data[:species].name : SpeciesName.import_data(data)
  end

end
