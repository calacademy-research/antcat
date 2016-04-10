class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.belongs_to :trackable, polymorphic: true
      t.belongs_to :user
      t.string :action
      t.text :parameters

      t.timestamps
    end

    add_index :activities, [:trackable_id, :trackable_type]
    add_index :activities, [:user_id]
  end
end
