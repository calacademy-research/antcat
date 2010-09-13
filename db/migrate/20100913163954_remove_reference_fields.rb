class RemoveReferenceFields < ActiveRecord::Migration
  def self.up
    remove_column :references, :series, :volume, :start_page, :end_page, :journal_title, :place, :citation
  end

  def self.down
    add_column :references, :series, :volume, :start_page, :end_page, :journal_title, :place, :citation
  end
end
