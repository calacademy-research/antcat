class RemoveKeyEnabledAndSelectorEnabledAndSelectorFromTooltips < ActiveRecord::Migration[5.2]
  def change
    remove_column :tooltips, :key_enabled, :boolean, default: true, null: false
    remove_column :tooltips, :selector_enabled, :boolean
    remove_column :tooltips, :selector, :string
  end
end
