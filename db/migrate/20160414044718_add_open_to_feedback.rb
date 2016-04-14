class AddOpenToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :open, :boolean, default: true
  end
end
