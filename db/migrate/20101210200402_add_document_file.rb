class AddDocumentFile < ActiveRecord::Migration
  def self.up
    create_table :document_files, :force => true do |t|
      t.string :url
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :document_files
  end
end
