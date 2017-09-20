class AddAutomatedEditToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :automated_edit, :boolean, default: false
  end
end
