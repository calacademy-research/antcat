class ChangeDefaultValueOfKeyEnabledInTooltips < ActiveRecord::Migration
  def up
    change_column :tooltips, :key_enabled, :boolean, default: false
  end

  def down
    change_column :tooltips, :key_enabled, :boolean, default: true
  end
end
