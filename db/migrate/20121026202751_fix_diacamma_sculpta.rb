class FixDiacammaSculpta < ActiveRecord::Migration
  def up
    sculpta = Taxon.find_by_name 'Diacamma sculpta'
    return unless sculpta
    rugosum_sculptum_name = Name.find_by_name 'Diacamma rugosum sculptum'
    return unless rugosum_sculptum_name
    rugosum = Taxon.find_by_name 'Diacamma rugosum'
    sculpta.update_attributes species_id: rugosum.id, name_id: rugosum_sculptum_name.id
  end
end
