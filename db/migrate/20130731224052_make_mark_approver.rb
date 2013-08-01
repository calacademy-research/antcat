class MakeMarkApprover < ActiveRecord::Migration
  def up
    User.find_by_email('mark@mwilden.com').update_attributes! can_approve_changes: true rescue nil
  end
end
