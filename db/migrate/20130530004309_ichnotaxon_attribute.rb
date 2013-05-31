class IchnotaxonAttribute < ActiveRecord::Migration
  def up
    add_column :taxa, :ichnotaxon, :boolean
    Taxon.where(status: 'ichnotaxon').update_all ichnotaxon: true, status: 'valid'
  end

  def down
    Taxon.where(ichnotaxon: true).update_all status: 'ichnotaxon'
    remove_column :taxa, :ichnotaxon
  end
end
