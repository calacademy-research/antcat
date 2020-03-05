class ExpandJsonTextField < ActiveRecord::Migration[4.2]
  def up
    change_column :hol_taxon_data, :json, :text, size: 4294967295, limit: 4294967295
  end

  def down
  end
end
