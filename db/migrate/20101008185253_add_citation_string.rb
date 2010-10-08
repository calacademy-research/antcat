class AddCitationString < ActiveRecord::Migration
  def self.up
    add_column :references, :citation_string, :string
  end

  def self.down
    remove_column :references, :citation_string
  end
end
