class CreateNewReferences < ActiveRecord::Migration
  def self.up
    create_table :references do |t|
      t.string :type

      # BookReference
      t.string :publisher

      t.integer :year
      t.timestamps
    end
    add_column :ward_references, :reference_id, :integer
    remove_column :ward_references, :publisher
  end

  def self.down
    remove_column :ward_references, :reference_id
    add_column :ward_references, :publisher, :string
    drop_table :references
  end
end
