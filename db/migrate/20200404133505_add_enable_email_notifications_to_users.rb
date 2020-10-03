# frozen_string_literal: true

class AddEnableEmailNotificationsToUsers < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_column :users, :enable_email_notifications, :boolean, default: true, nil: false
    end
  end
end
