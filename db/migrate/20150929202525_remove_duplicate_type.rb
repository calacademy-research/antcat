class RemoveDuplicateType < ActiveRecord::Migration[4.2]
  def change
    remove_column :taxa, :duplicate_type
  end
end
