class AddSpeciesEpithetToName < ActiveRecord::Migration
  def change
    add_column :names, :epithet, :string
  end
end
