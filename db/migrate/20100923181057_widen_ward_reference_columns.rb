class WidenWardReferenceColumns < ActiveRecord::Migration
  def self.up
    change_table :ward_references do |t|
      t.remove :authors, :citation, :notes, :taxonomic_notes, :title
      t.text :authors, :citation, :notes, :taxonomic_notes, :title
    end
  end

  def self.down
    change_table :ward_references do |t|
      t.remove :authors, :citation, :notes, :taxonomic_notes, :title
      t.string :authors, :citation, :notes, :taxonomic_notes, :title
    end
  end
end
