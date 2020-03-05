class RemoveEmailRecipientsFromFeedback < ActiveRecord::Migration[4.2]
  def change
    remove_column :feedbacks, :email_recipients, :text
  end
end
