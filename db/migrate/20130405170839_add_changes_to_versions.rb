class AddChangesToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :changes, :text
  end
end
