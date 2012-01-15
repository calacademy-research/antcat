class CreateText < ActiveRecord::Migration
  def self.up
    create_table :texts, force: true do |t|
      t.text :marked_up_text
      t.timestamps
    end

    create_table :references_texts, id: false, force: true do |t|
      t.integer :text_id
      t.integer :reference_id
    end
  end

  def self.down
    drop_table :references_texts
    drop_table :texts
  end
end
