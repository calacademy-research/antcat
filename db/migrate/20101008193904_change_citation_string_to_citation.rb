class ChangeCitationStringToCitation < ActiveRecord::Migration
  def self.up
    rename_column :references, :citation_string, :citation
  end

  def self.down
    rename_column :references, :citation, :citation_string
  end
end
