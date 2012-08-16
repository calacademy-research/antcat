class RenameNameFields < ActiveRecord::Migration
  def up
    drop_table :names rescue nil
    create_table :names, force: true do |t|
      t.string :type
      t.string :name
      t.string :name_html
      t.string :epithet
      t.string :epithet_html
      t.string :epithets
      t.string :protonym_html
      t.timestamps
    end
  end
  def down
    drop_table :names rescue nil
    create_table :names, force: true do |t|
      t.string :type
    end
  end
end
