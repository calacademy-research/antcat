class CreateBoltonMatches < ActiveRecord::Migration
  def self.up
    create_table :bolton_matches do |t|
      t.integer :bolton_reference_id
      t.integer :reference_id
      t.timestamps
    end
  end

  def self.down
    drop_table :bolton_matches
  end
end
