class AddFormattedCache < ActiveRecord::Migration
  def up
    add_column :references, :formatted_cache, :text
  end

  def down
    remove_column :references, :formatted_cache
  end
end
