class ExpandJsonTextField < ActiveRecord::Migration
  def up
    change_column :hol_taxon_data, :json, :text, size: 4294967295, limit: 4294967295
  end

  def down
  end
end


