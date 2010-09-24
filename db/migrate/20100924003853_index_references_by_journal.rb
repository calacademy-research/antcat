class IndexReferencesByJournal < ActiveRecord::Migration
  def self.up
    add_index :references, :journal_id, :name => 'references_journal_id_idx'
  end

  def self.down
    remove_index :references, :name => 'references_journal_id_idx'
  end
end
