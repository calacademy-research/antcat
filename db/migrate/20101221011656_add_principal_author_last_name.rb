class AddPrincipalAuthorLastName < ActiveRecord::Migration
  def self.up
    add_column :references, :principal_author_last_name, :string
    Reference.all.each(&:save!)
  end

  def self.down
    remove_column :references, :principal_author_last_name
  end
end
