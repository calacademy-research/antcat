class MakeFossilAndHongTwoValued < ActiveRecord::Migration
  def up
    change_column :taxa, :fossil, :boolean, default: 0, null: false
    change_column :taxa, :hong, :boolean, default: 0, null: false
  end

  def down
    change_column :taxa, :hong, :boolean, null: true
    change_column :taxa, :fossil, :boolean, null: true
  end
end
