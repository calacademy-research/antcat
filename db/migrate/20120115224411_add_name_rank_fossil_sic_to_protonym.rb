class AddNameRankFossilSicToProtonym < ActiveRecord::Migration
  def change
    add_column :protonyms, :rank, :string
    add_column :protonyms, :fossil, :boolean
    add_column :protonyms, :sic, :boolean
  end
end
