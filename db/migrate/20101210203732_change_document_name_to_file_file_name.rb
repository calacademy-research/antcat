class ChangeDocumentNameToFileFileName < ActiveRecord::Migration
  def self.up
    rename_column :documents, :name, :file_file_name
  end

  def self.down
    rename_column :documents, :file_file_name, :name
  end
end
