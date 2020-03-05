class ChangeDefaultValueOfKeyEnabledInTooltips < ActiveRecord::Migration[4.2]
  def up
    change_column :tooltips, :key_enabled, :boolean, default: false
  end

  def down
    change_column :tooltips, :key_enabled, :boolean, default: true
  end
end
