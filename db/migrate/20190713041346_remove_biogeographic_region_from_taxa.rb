# Moved to `protonyms` in `MoveBiogeographicRegionToProtonyms`.

class RemoveBiogeographicRegionFromTaxa < ActiveRecord::Migration[5.2]
  def change
    remove_column :taxa, :biogeographic_region, :string
  end
end
