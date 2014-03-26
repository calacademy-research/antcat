class InitializeChinaBiogeographicRegions < ActiveRecord::Migration
  def up
    Taxon.initialize_china_biographic_regions
  end
end
