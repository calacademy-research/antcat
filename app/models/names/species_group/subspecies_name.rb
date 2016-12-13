class SubspeciesName < SpeciesGroupName
  def subspecies_epithets
    words[2..-1].join ' '
  end

  def change_parent species_name
    name_string = [species_name.genus_epithet, species_name.species_epithet, subspecies_epithets].join ' '
    change name_string
    update! epithets: species_name.epithet + ' ' + subspecies_epithets
  end
end
