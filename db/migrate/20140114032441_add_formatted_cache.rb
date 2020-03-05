class AddFormattedCache < ActiveRecord::Migration[4.2]
  def up
    add_column :references, :formatted_cache, :text
  end

  def down
    remove_column :references, :formatted_cache
  end
end
