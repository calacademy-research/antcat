class CreateNames < ActiveRecord::Migration
  def change
    create_table :names, force: true do |t|
      t.string :name
      t.timestamps
    end
  end
end
