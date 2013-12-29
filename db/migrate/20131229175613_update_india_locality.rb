class UpdateIndiaLocality < ActiveRecord::Migration
  def up
    Taxon.joins(:protonym).where('locality = ?', 'India').update_all biogeographic_region: 'Indomalaya'
  end

  def down
  end
end
