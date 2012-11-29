class FixBrownAuthorship < ActiveRecord::Migration
  def up
    execute "UPDATE citations SET reference_id = 130850 WHERE id = 174187"
  end
end
