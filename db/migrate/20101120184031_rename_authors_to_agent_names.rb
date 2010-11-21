class RenameAuthorsToAgentNames < ActiveRecord::Migration
  def self.up
    rename_table :authors, :agent_names
    rename_column :author_participations, :author_id, :agent_name_id
    rename_column :references, :authors_string, :agent_names_string
    rename_column :references, :authors_suffix, :agent_names_suffix
  end

  def self.down
    rename_column :references, :agent_names_suffix, :authors_suffix
    rename_column :references, :agent_names_string, :authors_string
    rename_column :author_participations, :agent_name_id, :author_id
    rename_table :agent_names, :authors
  end
end
