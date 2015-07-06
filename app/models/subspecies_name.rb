# coding: UTF-8
class SubspeciesName < SpeciesGroupName
  extend Formatters::Formatter
  has_paper_trail meta: {change_id: :get_current_change_id}

  def subspecies_epithets
    words[2..-1].join ' '
  end

  def change_parent species_name
    name_string = [species_name.genus_epithet, species_name.species_epithet, subspecies_epithets].join ' '
    change name_string
    update_attributes! epithets: species_name.epithet + ' ' + subspecies_epithets
  end

  def self.parse_words words
    return unless words.size > 2
    genus   = words[0]
    species = words[1]
    epithets= words[1..-1].join ' '
    epithet = words[-1]
    name = "#{genus} #{epithets}"
    name_html = italicize name
    attributes = {
      name:         name,
      name_html:    name_html,
      epithet:      epithet,
      epithet_html: italicize(epithet),
      epithets:     epithets,
      protonym_html:name_html,
    }
    create! attributes
  end

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
      # strip types ("subsp.", "var.") in the name, but leave them in for the protonym
      type = subspecies[:type]
      if type
        epithets_with_subspecies_types_html << type << ' '
      end
      epithet_html = italicize epithet
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

    attributes[:protonym_html] = parent_name.protonym_html + ' ' + epithets_with_subspecies_types_html
    attributes
  end

  def self.get_parent_name data
    data[:species] ? data[:species].name : SpeciesName.import_data(data)
  end

end
