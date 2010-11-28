class BoltonReferenceFields < ActiveRecord::Migration
  def self.up
    change_table :bolton_references do |t|
      t.remove  :title_and_citation
      t.string  :title
      t.string  :journal
      t.string  :series_volume_issue
      t.string  :pagination
    end
  end

  def self.down
    change_table :bolton_references do |t|
      t.string  :title_and_citation
      t.remove  :title
      t.remove  :journal
      t.remove  :series_volume_issue
      t.remove  :pagination
    end
  end
end
