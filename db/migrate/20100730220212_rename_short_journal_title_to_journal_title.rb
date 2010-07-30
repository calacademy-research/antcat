class RenameShortJournalTitleToJournalTitle < ActiveRecord::Migration
    def self.up
      rename_column :refs, :short_journal_title, :journal_title
    end

    def self.down
      rename_column :refs, :journal_title, :short_journal_title
    end
end
