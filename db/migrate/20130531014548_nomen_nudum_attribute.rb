class NomenNudumAttribute < ActiveRecord::Migration
  def up
    add_column :taxa, :nomen_nudum, :boolean
    Taxon.where(status: 'nomen nudum').update_all nomen_nudum: true, status: 'unavailable'
  end

  def down
    Taxon.where(nomen_nudum: true).update_all status: 'nomen nudum'
    remove_column :taxa, :nomen_nudum
  end
end
