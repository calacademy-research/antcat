class RemoveReceiveFeedbackEmailsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :receive_feedback_emails, :boolean
  end
end
