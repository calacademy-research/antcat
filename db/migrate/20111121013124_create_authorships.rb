# coding: UTF-8
class CreateAuthorships < ActiveRecord::Migration
  def self.up
    create_table :authorships, :force => true do |t|
      t.integer     :reference_id
      t.string      :pages
      t.timestamps
    end
    add_index :authorships, :reference_id

    add_column :protonyms, :authorship_id, :integer
    add_index :protonyms, :authorship_id
  end

  def self.down
    remove_index :protonyms, :column => :authorship_id
    remove_column :protonyms, :authorship_id

    remove_index :authorships, :column => :reference_id
    drop_table :authorships
  end
end
