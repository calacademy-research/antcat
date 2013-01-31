class MakeFlagsNonnullable < ActiveRecord::Migration
  def up
    change_column :taxa, :unidentifiable, :boolean, null: false, default: 0
    change_column :taxa, :unresolved_homonym, :boolean, null: false, default: 0
  end
end
