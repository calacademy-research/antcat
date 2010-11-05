class AddPlaceTable < ActiveRecord::Migration
  def self.up
    create_table :places, :force => true do |t|
      t.string :name
      t.boolean :verified
      t.timestamps
    end
    change_table :publishers do |t|
      t.remove :place
      t.integer :place_id
    end
  end

  def self.down
    change_table :publishers do |t|
      t.remove :place_id
      t.string :place
    end
    drop_table :places
  end
end
