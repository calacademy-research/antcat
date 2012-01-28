class AddReferenceSections < ActiveRecord::Migration
  def up
    create_table :reference_sections, force: true do |t|
      t.integer :taxon_id
      t.integer :position
      t.string  :title
      t.text    :references
    end
    add_index :reference_sections, [:taxon_id, :position]
    remove_column :taxa, :references_taxt
  end

  def down
    remove_index :reference_sections, :column => [:taxon_id, :position]
    drop_table :reference_sections
  end
end
