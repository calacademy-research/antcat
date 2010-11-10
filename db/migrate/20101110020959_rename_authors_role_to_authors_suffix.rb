class RenameAuthorsRoleToAuthorsSuffix < ActiveRecord::Migration
  def self.up
    rename_column :references, :authors_role, :authors_suffix
  end

  def self.down
    rename_column :references, :authors_suffix, :authors_role
  end
end
