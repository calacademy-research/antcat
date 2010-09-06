class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues, :force => true do |t|
      t.string :series, :volume, :issue
      t.integer :journal_id
      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
