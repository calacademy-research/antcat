class RemoveWardReferenceFields < ActiveRecord::Migration
  def self.up
    change_table :ward_references do |t|
      t.remove :pagination, :kind, :numeric_year
    end
  end

  def self.down
    change_table :ward_references do |t|
      t.string :journal_title, :series, :volume, :issue, :start_page, :end_page, :place, :publisher, :pagination, :kind
      t.integer :numeric_year
    end
  end
end
