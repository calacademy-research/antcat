class SpeciesName < SpeciesGroupName
  def change_parent parent_name
    name_string = [parent_name.genus_epithet, species_epithet].join ' '
    change name_string
  end
end
