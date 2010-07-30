class CreateJournalsTable < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.string :title
      t.string :short_title
      t.timestamps
    end
  end

  def self.down
    drop_table :journals
  end
end
