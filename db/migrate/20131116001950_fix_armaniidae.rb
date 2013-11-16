class FixArmaniidae < ActiveRecord::Migration
  def up
    name_string = 'Armaniidae'
    armaniidae = Taxon.where(name_cache: name_string).first
    family_or_subfamily_name = FamilyOrSubfamilyName.where(name: name_string).first
    genus_name = GenusName.where(name: name_string).first

    armaniidae.update_attributes! name_id: family_or_subfamily_name.id
    genus_name.destroy
  end

  def down
  end
end
