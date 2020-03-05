class CreateSiteNotice < ActiveRecord::Migration[4.2]
  def change
    create_table :site_notices do |t|
      t.string :title
      t.text :message
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
