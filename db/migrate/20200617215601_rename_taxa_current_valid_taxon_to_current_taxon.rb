# frozen_string_literal: true

class RenameTaxaCurrentValidTaxonToCurrentTaxon < ActiveRecord::Migration[6.0]
  def change
    rename_column :taxa, :current_valid_taxon_id, :current_taxon_id
  end
end
