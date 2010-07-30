class RelateReferencesToJournals < ActiveRecord::Migration
  def self.up
    remove_column :refs, :short_journal_title
    add_column :refs, :journal_id, :integer
  end

  def self.down
    remove_column :refs, :journal_id
    add_column :refs, :short_journal_title, :string
  end
end
