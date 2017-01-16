class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :notifier, index: true
      t.belongs_to :attached, polymorphic: true, index: true
      t.boolean :seen, default: false, null: false
      t.string :reason, null: false

      t.timestamps null: false
    end
  end
end
