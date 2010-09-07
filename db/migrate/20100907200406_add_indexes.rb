class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :author_participations, :author_id, :name => 'author_participations_author_id_idx'
    add_index :authors, :name, :name => 'author_name_idx'
  end

  def self.down
    remove_index :author_participations, :name => 'author_participations_author_id_idx'
    remove_index :authors, :name => 'author_name_idx'
  end
end
