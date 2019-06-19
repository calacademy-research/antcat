# NOTE: Timestamps in migrations went bonkers after `MoreBooleanColumnDefaultsAndNotNulls`.

class CreateWikiPages < ActiveRecord::Migration[5.2]
  def change
    create_table :wiki_pages do |t|
      t.string :title, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
