class AddPaperclip < ActiveRecord::Migration
  def self.up
    change_table :references do |t|
      t.string :source_file_name
    end
  end

  def self.down
    change_table :references do |t|
      t.remove :source_file_name
    end
  end
end
