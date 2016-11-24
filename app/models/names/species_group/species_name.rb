class SpeciesName < SpeciesGroupName
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def change_parent parent_name
    name_string = [parent_name.genus_epithet, species_epithet].join ' '
    change name_string
    update_attributes! epithets: epithet
  end
end
