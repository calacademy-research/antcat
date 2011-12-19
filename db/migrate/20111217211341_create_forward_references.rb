class CreateForwardReferences < ActiveRecord::Migration
  def self.up
    create_table :forward_references, :force => true do |t|
      t.integer :source_id
      t.string  :source_attribute
      t.string  :target_name
    end
  end

  def self.down
    drop_table :forward_references
  end
end
