class RemoveReceiveFeedbackEmailsFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :receive_feedback_emails, :boolean
  end
end
