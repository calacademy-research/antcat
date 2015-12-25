class RenameTooltipEnabledField < ActiveRecord::Migration
  def change
    rename_column :tooltips, :enabled, :key_enabled
  end
end
