class AddRecordsToHolDetails < ActiveRecord::Migration[4.2]
  def change
    add_column :hol_taxon_data, :author_last_name, :string
    add_column :hol_taxon_data, :antcat_author_id, :integer
    add_column :hol_taxon_data, :journal_name, :string
    add_column :hol_taxon_data, :hol_journal_id, :integer
    add_column :hol_taxon_data, :antcat_journal_id, :integer
    add_column :hol_taxon_data, :year, :integer
    add_column :hol_taxon_data, :hol_pub_id, :integer
    add_column :hol_taxon_data, :start_page, :integer
    add_column :hol_taxon_data, :end_page, :integer
    add_column :hol_taxon_data, :antcat_protonym_id, :integer
  end
end
