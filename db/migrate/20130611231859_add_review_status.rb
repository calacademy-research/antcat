class AddReviewStatus < ActiveRecord::Migration
  def up
    add_column :references, :review_status, :string
  end

  def down
    remove_column :references, :review_status
  end
end
