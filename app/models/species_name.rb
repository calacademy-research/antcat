class SpeciesName < SpeciesGroupName

  def self.parse_words words
    return unless words.size == 2
    genus = words[0]
    species = words[1]
    attributes = {
      name: "#{genus} #{species}",
      name_html: "<i>#{genus} #{species}</i>",
      epithet: species,
      epithet_html: "<i>#{species}</i>",
      protonym_html: "<i>#{species}</i>",
    }
    create! attributes
  end

  def self.get_name data
    data[:species_epithet] || data[:species_group_epithet]
  end

  def self.get_parent_name data
    @subgenus_name = nil
    if data[:subgenus_epithet]
      @subgenus_name = SubgenusName.import_data data
    end
    if data[:genus]
      data[:genus].name
    elsif data[:genus_name]
      if data[:genus_name].kind_of?(Name)
        genus_name = data[:genus_name]
      else
        genus_name = GenusName.import_data data
      end
      genus_name
    else
      genus_name
    end
  end

  def self.make_import_attributes name, data
    attributes = {
      epithet:      name,
      epithet_html: Formatters::Formatter.italicize(name),
    }
    parent_name = get_parent_name data
    attributes[:name]          = "#{parent_name} #{attributes[:epithet]}"
    attributes[:name_html]     = "#{parent_name.to_html} #{attributes[:epithet_html]}"
    if @subgenus_name
      attributes[:protonym_html] = "#{@subgenus_name.protonym_html} #{attributes[:epithet_html]}"
    else
      attributes[:protonym_html] = "#{parent_name.to_html} #{attributes[:epithet_html]}"
    end

    attributes
  end

end
