class AddNewAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors, :force => true do |t|
      t.timestamps
    end
    add_column :author_names, :author_id, :integer

    AuthorName.all.each do |author_name|
      author_name.author = Author.create!
      author_name.save!
    end
  end

  def self.down
    remove_column :author_names, :author_id
    drop_table :authors
  end
end
