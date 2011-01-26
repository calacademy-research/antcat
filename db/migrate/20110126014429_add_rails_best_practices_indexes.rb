class AddRailsBestPracticesIndexes < ActiveRecord::Migration
  def self.up
    add_index :author_names, :author_id, :name => 'author_names_author_id_idx'
    add_index :bolton_references, :ward_reference_id, :name => 'bolton_references_ward_reference_id_idx'
    add_index :bolton_matches, :bolton_reference_id, :name => 'bolton_matches_bolton_reference_id_idx'
    add_index :bolton_matches, :reference_id, :name => 'bolton_matches_reference_id_idx'
    add_index :duplicate_references, :reference_id, :name => 'duplicate_references_reference_id_idx'
    add_index :duplicate_references, :duplicate_id, :name => 'duplicate_references_duplicate_id_idx'
    add_index :publishers, :place_id, :name => 'publishers_place_id_idx'
    add_index :references, :publisher_id, :name => 'references_publisher_id_idx'
    add_index :references, :journal_id, :name => 'references_journal_id_idx'
    add_index :references, :source_reference_id, :name => 'references_source_reference_id_idx'
    add_index :references, :nested_reference_id, :name => 'references_nested_reference_id_idx'
    add_index :taxa, :parent_id, :name => 'taxa_parent_id_idx'
    add_index :ward_references, :reference_id, :name => 'ward_references_reference_id_idx'
  end

  def self.down
    remove_index :ward_references, :name => 'ward_references_reference_id_idx'
    remove_index :taxa, :name => 'taxa_parent_id_idx'
    remove_index :references, :name => 'references_nested_reference_id_idx'
    remove_index :references, :name => 'references_source_reference_id_idx'
    remove_index :references, :name => 'references_journal_id_idx'
    remove_index :references, :name => 'references_publisher_id_idx'
    remove_index :publishers, :name => 'publishers_place_id_idx'
    remove_index :duplicate_references, :name => 'duplicate_references_duplicate_id_idx'
    remove_index :duplicate_references, :name => 'duplicate_references_reference_id_idx'
    remove_index :bolton_matches, :name => 'bolton_matches_reference_id_idx'
    remove_index :bolton_matches, :name => 'bolton_matches_bolton_reference_id_idx'
    remove_index :bolton_references, :name => 'bolton_references_ward_reference_id_idx'
    remove_index :author_names, :name => 'author_names_author_id_idx'
  end
end
