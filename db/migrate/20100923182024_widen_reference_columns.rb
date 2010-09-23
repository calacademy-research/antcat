class WidenReferenceColumns < ActiveRecord::Migration
  def self.up
    change_table :references do |t|
      t.remove :authors_string, :editor_notes, :public_notes, :taxonomic_notes, :title
      t.text :authors_string, :editor_notes, :public_notes, :taxonomic_notes, :title
    end
  end

  def self.down
    change_table :references do |t|
      t.remove :authors_string, :editor_notes, :public_notes, :taxonomic_notes, :title
      t.string :authors_string, :editor_notes, :public_notes, :taxonomic_notes, :title
    end
  end
end
