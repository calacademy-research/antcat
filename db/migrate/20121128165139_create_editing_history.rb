class CreateEditingHistory < ActiveRecord::Migration
  def up
    create_table :editing_history, force: true do |t|
      t.string :type
      t.integer :user_id

      # ReverseSynonymyEdit
      t.integer :new_junior_id
      t.integer :new_senior_id

      t.timestamps
    end
  end

  def down
  end
end
