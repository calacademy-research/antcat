# TODO: Remove blanked data migrations like this one.

class DisableTooltipSelectors < ActiveRecord::Migration[4.2]
  def change
    # Tooltip.find_each do |tooltip|
    #   tooltip.update(key_enabled: true, selector_enabled: false)
    # end
  end
end
