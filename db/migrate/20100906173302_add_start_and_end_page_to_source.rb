class AddStartAndEndPageToSource < ActiveRecord::Migration
  def self.up
    change_table :sources do |t|
      t.string :start_page, :end_page
    end
  end

  def self.down
    change_table :sources do |t|
      t.remove :start_page, :end_page
    end
  end
end
