class CreateChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.references :version
      t.timestamps
    end
  end
end
