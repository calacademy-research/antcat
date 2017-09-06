class RemoveEmailRecipientsFromFeedback < ActiveRecord::Migration
  def change
    remove_column :feedbacks, :email_recipients, :text
  end
end
