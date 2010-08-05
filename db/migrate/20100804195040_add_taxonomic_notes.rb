class AddTaxonomicNotes < ActiveRecord::Migration
  def self.up
    add_column :refs, :taxonomic_notes, :string
  end

  def self.down
    remove_column :refs, :taxonomic_notes
  end
end
