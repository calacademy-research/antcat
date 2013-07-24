class RenameReviewStatusToReviewState < ActiveRecord::Migration
  def up
    rename_column :references, :review_status, :review_state
    rename_column :taxa, :review_status, :review_state
  end

  def down
    rename_column :taxa, :review_state, :review_status
    rename_column :references, :review_state, :review_status
  end
end
