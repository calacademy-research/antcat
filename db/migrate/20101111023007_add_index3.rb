class AddIndex3 < ActiveRecord::Migration
  def self.up
    add_index :author_participations, [:reference_id, :position], :name => 'author_participations_reference_id_position_idx'
  end

  def self.down
    remove_index :author_participations, :name => ':author_participations_reference_id_position_idx'
  end
end
