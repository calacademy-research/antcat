class FixSynonymCycles < ActiveRecord::Migration
  def up
    remove_junior_synonymy 'Brachymyrmex patagonicus brevicornoeides'
    remove_junior_synonymy 'Formica sanguinea aserva'
    remove_junior_synonymy 'Odontomachus meinerti'
    remove_junior_synonymy 'Strongylognathus kratochvili'

    taxon = Taxon.find_by_name_cache 'Formica sanguinea aserva'
    taxon.name.epithets = 'sanguinea aserva'
    taxon.name.save!
  end

  def remove_junior_synonymy name
    taxon = Taxon.find_by_name_cache name
    Synonym.destroy_all junior_synonym_id: taxon.id
    taxon.update_attribute :status, 'valid'
  end

  def down
  end
end
