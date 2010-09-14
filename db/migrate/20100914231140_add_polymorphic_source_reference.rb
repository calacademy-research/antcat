class AddPolymorphicSourceReference < ActiveRecord::Migration
  def self.up
    change_table :references do |t|
      t.integer :source_reference_id
      t.string :source_reference_type
    end
  end

  def self.down
    change_table :references do |t|
      t.remove :source_reference_id
      t.remove :source_reference_type
    end
  end
end
