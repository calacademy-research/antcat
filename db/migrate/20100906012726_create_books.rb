class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books, :force => true do |t|
      t.string :authors
      t.integer :year
      t.string :title
      t.string :place
      t.string :publisher
      t.string :pagination
    end
    add_column :references, :source_id, :integer
  end

  def self.down
    remove_column :references, :source_id
    drop_table :books
  end
end
