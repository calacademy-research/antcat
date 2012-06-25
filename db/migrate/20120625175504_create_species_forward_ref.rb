class CreateSpeciesForwardRef < ActiveRecord::Migration
  def change
    create_table :species_forward_refs do |t|
      t.integer    :fixee_id
      t.string     :fixee_attribute
      t.references :genus
      t.string     :epithet
      t.timestamps
    end
  end
end
