# See https://github.com/calacademy-research/antcat/issues/163

class ChangeTaxonVerbatimTypeLocalityToText < ActiveRecord::Migration[4.2]
  def up
    change_column :taxa, :verbatim_type_locality, :text
  end

  def down
    # Something like this (but it will cause issues with strings longer than 255 bytes).
    # change_column :taxa, :verbatim_type_locality, :string
  end
end
