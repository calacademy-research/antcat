class RenameAgentNameToAuthorName < ActiveRecord::Migration
  def self.up
    rename_table :agent_names, :author_names
    rename_column :author_participations, :agent_name_id, :author_name_id
    rename_column :references, :agent_names_string, :author_names_string
    rename_column :references, :agent_names_suffix, :author_names_suffix
  end

  def self.down
    rename_column :references, :author_names_suffix, :agent_names_suffix
    rename_column :references, :author_names_string, :agent_names_string
    rename_column :author_participations, :author_name_id, :agent_name_id
    rename_table :author_names, :agent_names
  end
end
