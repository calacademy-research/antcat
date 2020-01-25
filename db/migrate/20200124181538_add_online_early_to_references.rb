class AddOnlineEarlyToReferences < ActiveRecord::Migration[5.2]
  def change
    add_column :references, :online_early, :boolean, null: false, default: false
  end
end
