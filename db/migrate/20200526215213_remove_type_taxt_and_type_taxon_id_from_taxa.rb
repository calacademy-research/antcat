# frozen_string_literal: true

class RemoveTypeTaxtAndTypeTaxonIdFromTaxa < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_column :taxa, :type_taxon_id, :integer
      remove_column :taxa, :type_taxt, :text
    end
  end
end
