class RemoveLimitFromInvitationToken < ActiveRecord::Migration[4.2]
  #from https://github.com/scambra/devise_invitable/blob/cc64e6e6972682f195cf436909ff0ea8b4089ef6/README.rdoc
  def up
    change_column :users, :invitation_token, :string, limit: nil
  end

  def down
    change_column :users, :invitation_token, :string, limit: 20
  end
end
