class AddDeviseInvitableColumns < ActiveRecord::Migration
  change_table :users do |t|
    t.datetime :invitation_accepted_at
    t.integer  :invitation_limit
    t.integer  :invited_by_id
    t.string   :invited_by_type
  end
end
