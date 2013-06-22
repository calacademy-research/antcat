class FixLimai < ActiveRecord::Migration
  def up
    Taxon.find(459803).destroy
  end
end
