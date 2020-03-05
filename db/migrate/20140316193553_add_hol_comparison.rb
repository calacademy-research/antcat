class AddHolComparison < ActiveRecord::Migration[4.2]
  def up
    create_table :hol_comparisons, force: true do |t|
      t.string :name
      t.string :status
    end
  end

  def down
    drop_table :hol_comparisons
  end
end
