class CreateGenera < ActiveRecord::Migration
  def self.up
    create_table :genera do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :genera
  end
end
