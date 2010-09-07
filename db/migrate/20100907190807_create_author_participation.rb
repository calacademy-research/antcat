class CreateAuthorParticipation < ActiveRecord::Migration
  def self.up
    create_table :author_participations, :force => true do |t|
      t.integer :author_id 
      t.integer :source_id 
      t.timestamps
    end
    remove_column :authors, :source_id
  end

  def self.down
    add_column :authors, :source_id, :integer
    drop_table :author_participations
  end
end
