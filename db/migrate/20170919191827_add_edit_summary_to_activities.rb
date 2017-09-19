class AddEditSummaryToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :edit_summary, :string, nil: true
  end
end
