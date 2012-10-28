class FixStrangulata < ActiveRecord::Migration
  def up
    taxon = Taxon.find_by_name 'Formica strangulata'
    taxon.update_attribute :status, 'valid'
  end
end
