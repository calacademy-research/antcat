class AddAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors, :force => true do |t|
      t.string :name
      t.integer :source_id
      t.timestamps
    end
  end

  def self.down
    drop_table :authors
  end
end
