class AddHolTaxonExpansionFields < ActiveRecord::Migration[4.2]
  def change
    add_column :hol_taxon_data, :antcat_reference_id, :integer
    add_column :hol_taxon_data, :antcat_name_id, :integer
    add_column :hol_taxon_data, :antcat_citation_id, :integer
    add_column :hol_taxon_data, :rank, :string
    add_column :hol_taxon_data, :rel_type, :string
    add_column :hol_taxon_data, :fossil, :boolean
    add_column :hol_taxon_data, :status, :string
  end
end
