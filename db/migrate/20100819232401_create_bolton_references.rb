class CreateBoltonReferences < ActiveRecord::Migration
  def self.up
    create_table :bolton_refs do |t|
      t.string :authors
      t.string :year
      t.string :title_and_citation
      t.string :date
      t.timestamps
    end
  end

  def self.down
    drop_table :bolton_refs
  end
end
