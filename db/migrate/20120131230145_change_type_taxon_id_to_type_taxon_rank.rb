class ChangeTypeTaxonIdToTypeTaxonRank < ActiveRecord::Migration
  def up
    remove_column :taxa, :type_taxon_id
    remove_column :forward_references, :source_attribute
    add_column :taxa, :type_taxon_rank, :string
  end

  def down
    remove_column :taxa, :type_taxon_rank
    add_column :forward_references, :source_attribute, :string
    add_column :taxa, :type_taxon_id, :integer
  end
end
