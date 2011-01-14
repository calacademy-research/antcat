class CreateTaxon < ActiveRecord::Migration
  def self.up
    create_table :taxa, :force => true do |t|
      t.string :name
      t.string :rank
      t.integer :parent_id
      t.boolean :available
      t.boolean :is_valid
      t.timestamps
    end
  end

  def self.down
  end
end
