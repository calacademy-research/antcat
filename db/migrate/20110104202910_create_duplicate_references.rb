class CreateDuplicateReferences < ActiveRecord::Migration
  def self.up
    create_table :duplicate_references, :force => true do |t|
      t.timestamps
      t.integer :reference_id
      t.integer :duplicate_id
      t.float :similarity
    end
  end

  def self.down
    drop_table :duplicate_references
  end
end
