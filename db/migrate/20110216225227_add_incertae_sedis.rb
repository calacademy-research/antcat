class AddIncertaeSedis < ActiveRecord::Migration
  def self.up
    add_column :taxa, :incertae_sedis_in, :string
  end

  def self.down
    remove_column :taxa, :incertae_sedis_in
  end
end
