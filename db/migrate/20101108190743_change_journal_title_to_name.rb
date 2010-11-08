class ChangeJournalTitleToName < ActiveRecord::Migration
  def self.up
    rename_column :journals, :title, :name
  end

  def self.down
    rename_column :journals, :name, :title
  end
end
