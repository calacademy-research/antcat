# coding: UTF-8
class SpeciesName < SpeciesGroupName
  extend Formatters::Formatter
  include UndoTracker

  has_paper_trail meta: {change_id: :get_current_change_id}

  def change_parent parent_name
    name_string = [parent_name.genus_epithet, species_epithet].join ' '
    change name_string
    update_attributes! epithets: epithet
  end
end