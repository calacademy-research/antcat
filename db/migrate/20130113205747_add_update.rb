class AddUpdate < ActiveRecord::Migration
  def up
    create_table :updates, force: true do |t|
      t.string  :class_name
      t.integer :taxon_id
      t.string  :field_name
      t.string  :before
      t.string  :after
      t.timestamps
    end
  end

  def down
  end
end
