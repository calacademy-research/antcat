class AddReceiveFeedbackEmailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :receive_feedback_emails, :boolean, default: false
    add_column :feedbacks, :email_recipients, :text
  end
end
