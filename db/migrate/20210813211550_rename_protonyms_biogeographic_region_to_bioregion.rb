# frozen_string_literal: true

class RenameProtonymsBiogeographicRegionToBioregion < ActiveRecord::Migration[6.1]
  def change
    rename_column :protonyms, :biogeographic_region, :bioregion
  end
end
