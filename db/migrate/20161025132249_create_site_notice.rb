class CreateSiteNotice < ActiveRecord::Migration
  def change
    create_table :site_notices do |t|
      t.string :title
      t.text :message
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
