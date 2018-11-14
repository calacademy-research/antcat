class ChangeTooltipsKeyEnabledDefault < ActiveRecord::Migration[5.1]
  def up
    change_column :tooltips, :key_enabled, :boolean, default: true, null: false
  end

  def down
    change_column :tooltips, :key_enabled, :boolean, default: false
  end
end
