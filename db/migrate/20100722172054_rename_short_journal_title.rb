class RenameShortJournalTitle < ActiveRecord::Migration
  def self.up
    rename_column :refs, :journal_short_title, :short_journal_title
  end

  def self.down
    rename_column :refs, :short_journal_title, :journal_short_title
  end
end
