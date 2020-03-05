class CreateTaskReference < ActiveRecord::Migration[4.2]
  def change
    create_table :task_references do |t|
      t.integer :task_id, index: true
      t.integer :taxon_id, index: true
    end
  end
end
