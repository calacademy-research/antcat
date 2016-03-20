class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :closer_id, index: true
      t.integer :adder_id, index: true
      t.string :status, default: "open"
      t.string :title
      t.text :description

      t.timestamps null: false
    end
  end
end
