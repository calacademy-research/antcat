# frozen_string_literal: true

class RemoveIchnotaxonFromTaxa < ActiveRecord::Migration[6.0]
  def change
    remove_column :taxa, :ichnotaxon, :boolean, default: false, null: false
  end
end
