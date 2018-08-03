class RenameChangesUserChangedTaxonIdToTaxonId < ActiveRecord::Migration[5.1]
  def change
    rename_column :changes, :user_changed_taxon_id, :taxon_id
  end
end
