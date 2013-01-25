class AddSpuriousToName < ActiveRecord::Migration
  def change
    add_column :names, :spurious, :boolean
  end
end
