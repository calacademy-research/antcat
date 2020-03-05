class AddAutomatedEditToActivities < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :automated_edit, :boolean, default: false
  end
end
