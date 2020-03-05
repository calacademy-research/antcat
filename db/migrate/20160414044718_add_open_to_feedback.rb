class AddOpenToFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :feedbacks, :open, :boolean, default: true
  end
end
