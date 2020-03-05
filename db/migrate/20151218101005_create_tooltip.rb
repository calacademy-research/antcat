class CreateTooltip < ActiveRecord::Migration[4.2]
  def up
    create_table :tooltips do |t|
      t.string :key
      t.text :text
      t.boolean :enabled, default: true
      t.string :selector
      t.boolean :selector_enabled, defaut: false

      t.timestamps
    end
  end

  def down
    drop_table :tooltips
  end
end
