class CreateWardReferencesAgain < ActiveRecord::Migration
  def self.up
    create_table :ward_references do |t|
      t.string  :authors,:citation, :cite_code, :date, :filename, :notes, :possess, :taxonomic_notes, :title, :year
      t.integer :reference_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ward_references
  end
end
