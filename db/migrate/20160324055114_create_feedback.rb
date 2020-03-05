class CreateFeedback < ActiveRecord::Migration[4.2]
  def change
    create_table :feedbacks do |t|
      t.references :user, index: true
      t.string :email
      t.string :name
      t.text :comment
      t.string :ip
      t.string :page
      t.timestamps
    end
  end
end
