# frozen_string_literal: true

class RemoveUnusedInvitationColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_column :users, :invitation_token, :string
      remove_column :users, :invitation_sent_at, :datetime
      remove_column :users, :invitation_accepted_at, :datetime
      remove_column :users, :invitation_limit, :integer
      remove_column :users, :invited_by_id, :integer
      remove_column :users, :invited_by_type, :string
      remove_column :users, :invitation_created_at, :datetime
    end
  end
end
