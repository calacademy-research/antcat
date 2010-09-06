class RemovePublisherYearFromReferences < ActiveRecord::Migration
  def self.up
    change_table :references do |t|
      t.remove :publisher, :year
    end
  end

  def self.down
    change_table :references do |t|
      t.string :publisher, :year
    end
  end
end
