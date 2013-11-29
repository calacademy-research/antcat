class AddProtonymToGlabrior < ActiveRecord::Migration
  def change
    citation = Citation.find 188789

    name = Name.find_by_name 'Prenolepis braueri glabrior'
    raise unless name.present?

    protonym = Protonym.create! name_id: name.id, authorship_id: citation.id, locality: 'Australia'

    glabrior = Taxon.find_by_name 'Prenolepis braueri glabrior'
    raise unless glabrior.present?

    glabrior.update_attributes! protonym_id: protonym.id, species_id: 458884
  end
end
