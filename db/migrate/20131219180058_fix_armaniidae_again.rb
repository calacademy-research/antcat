class FixArmaniidaeAgain < ActiveRecord::Migration
  def up
    armaniidae = Name.find_by_name 'Armaniidae'
    raise unless armaniidae
    armaniidae.update_attributes!(
      name:         'Armaniinae',
      name_html:    'Armaniinae',
      epithet:      'Armaniinae',
      epithet_html: 'Armaniinae',
      protonym_html:'Armaniidae'
    )
    taxon = Taxon.find_by_name 'Armaniinae'
    taxon.update_attributes status: 'valid'

    armaniini = Taxon.find_by_name 'Armaniini'
    armaniini.update_attributes status: 'valid'
    for genus in armaniini.genera
      genus.update_attributes! status: 'valid'
      for species in genus.species
        species.update_attributes! status: 'valid'
      end
      for subspecies in genus.species
        subspecies.update_attributes! status: 'valid'
      end
    end
  end

  def down
  end
end
