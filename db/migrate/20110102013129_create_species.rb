class CreateSpecies < ActiveRecord::Migration
  def self.up
    create_table :species, :force => true do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :species
  end
end
