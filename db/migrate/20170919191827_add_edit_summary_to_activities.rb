class AddEditSummaryToActivities < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :edit_summary, :string, nil: true
  end
end
