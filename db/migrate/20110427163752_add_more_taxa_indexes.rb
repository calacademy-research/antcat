# coding: UTF-8
class AddMoreTaxaIndexes < ActiveRecord::Migration
  def self.up
    add_index :taxa, :synonym_of_id, name: :taxa_synonym_of_id_index
    add_index :taxa, :species_id, name: :taxa_species_id_index
    add_index :taxa, :homonym_resolved_to_id, name: :taxa_homonym_resolved_to_id_index
    add_index :references, [:source_reference_id, :source_reference_type], name: :references_source_reference_id_source_reference_type_index
  end

  def self.down
    remove_index :references, name: :references_source_reference_id_source_reference_type_index
    remove_index :taxa, name: :taxa_homonym_resolved_to_id_index
    remove_index :taxa, name: :taxa_species_id_index
    remove_index :taxa, name: :taxa_synonym_of_id_index
  end
end
