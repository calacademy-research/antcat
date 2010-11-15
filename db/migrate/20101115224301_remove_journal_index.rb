class RemoveJournalIndex < ActiveRecord::Migration
  def self.up
    execute "DROP INDEX references_journal_id_idx ON `references`"
  end

  def self.down
    add_index :references, :journal_id, :name => 'references_journal_id_idx'
  end
end
