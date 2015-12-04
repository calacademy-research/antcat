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
end