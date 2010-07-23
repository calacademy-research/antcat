class RemoveExcelFileNameField < ActiveRecord::Migration
  def self.up
    remove_column :refs, :excel_file_name
  end

  def self.down
    add_column :refs, :excel_file_name, :string
  end
end
