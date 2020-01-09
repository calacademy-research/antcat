class RemoveEpithetsFromNames < ActiveRecord::Migration[5.2]
  def change
    remove_column :names, :epithets, :string
  end
end
