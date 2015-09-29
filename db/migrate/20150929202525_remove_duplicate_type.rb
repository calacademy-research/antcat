class RemoveDuplicateType < ActiveRecord::Migration
  def change
    remove_column :taxa, :duplicate_type
  end
end
