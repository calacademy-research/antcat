class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals, :force => true do |t|
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :journals
  end
end
