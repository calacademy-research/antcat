class FixNylanderia < ActiveRecord::Migration
  def up
    nylanderia = Taxon.find_by_name 'Nylanderia glabrior'
    prenolepsis = Taxon.find_by_name 'Prenolepis braueri glabrior'
    prenolepsis.update_attributes! current_valid_taxon: nylanderia
  end
end
