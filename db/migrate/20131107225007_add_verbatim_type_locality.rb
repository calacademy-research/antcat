class AddVerbatimTypeLocality < ActiveRecord::Migration
  def up
    add_column :taxa, :verbatim_type_locality, :string
  end

  def down
    remove_column :taxa, :verbatim_type_locality
  end
end
