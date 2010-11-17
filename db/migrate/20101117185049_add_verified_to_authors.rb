class AddVerifiedToAuthors < ActiveRecord::Migration
  def self.up
    add_column :authors, :verified, :boolean
  end

  def self.down
    remove_column :authors, :verified
  end
end
