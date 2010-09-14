class DropIssuesTable < ActiveRecord::Migration
  def self.up
    drop_table :issues
  end

  def self.down
    create_table :issues do |t|
    end
  end
end
