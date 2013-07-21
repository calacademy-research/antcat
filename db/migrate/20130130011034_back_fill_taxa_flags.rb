class BackFillTaxaFlags < ActiveRecord::Migration
  def up
    Taxon.update_all 'unidentifiable = 1, status = "valid"', status: 'unidentifiable'
    Taxon.update_all 'unresolved_homonym = 1, status = "valid"', status: 'unresolved homonym'
  end

  def down
  end
end
