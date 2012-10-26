class FixFormicaWhymperi < ActiveRecord::Migration
  def up
    whymperi = Taxon.find_by_name 'Formica whymperi'
    return unless whymperi
    adamsi_whymperi_name = Name.find_by_name 'Formica adamsi whymperi'
    return unless adamsi_whymperi_name
    adamsi = Taxon.find_by_name 'Formica adamsi'
    whymperi.update_attributes species_id: adamsi.id, name_id: adamsi_whymperi_name.id
  end
end
