class CreateReferences < ActiveRecord::Migration
  def self.up
    create_table :refs do |t|
      t.string :authors
      t.string :year
      t.string :title
      t.string :citation
      t.string :notes
      t.string :possess
      t.string :date
      t.string :excel_file_name
      t.datetime :created_at
      t.date_time :updated_at
      t.string :cite_code
      t.timestamps
    end
  end
  
  def self.down
    drop_table :refs
  end
end
