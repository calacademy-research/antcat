class RenameTooltipEnabledField < ActiveRecord::Migration[4.2]
  def change
    rename_column :tooltips, :enabled, :key_enabled
  end
end
