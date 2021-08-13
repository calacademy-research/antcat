# frozen_string_literal: true

class RenameProtonymsBiogeographicRegionToBioregion < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      rename_column :protonyms, :biogeographic_region, :bioregion
    end
  end
end
