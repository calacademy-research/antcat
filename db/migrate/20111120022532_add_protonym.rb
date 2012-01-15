class AddProtonym < ActiveRecord::Migration
  def self.up
    create_table :protonyms, :force => true do |t|
      t.string :name
      t.timestamps
    end
    add_column :taxa, :protonym_id, :integer
  end

  def self.down
    remove_column :taxa, :protonym_id
    drop_table :protonyms
  end
end
