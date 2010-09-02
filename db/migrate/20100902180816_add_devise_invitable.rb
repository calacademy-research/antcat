class AddDeviseInvitable < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :invitation_token, :limit => 20
      t.datetime :invitation_sent_at
      t.index :invitation_token
    end

    # Allow null encrypted_password and password_salt
    change_column :users, :encrypted_password, :string, :null => true
    change_column :users, :password_salt, :string, :null => true
  end

  def self.down
    change_column :users, :password_salt, :string, :null => false
    change_column :users, :encrypted_password, :string, :null => false
    remove_column :users, :invitation_token
    remove_column :users, :invitation_sent_at
    remove_index :users, :invitation_token
  end
end
