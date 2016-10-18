# TODO To be removed, see migration CopyHolIdToTaxon

class HolTaxonDatum < ActiveRecord::Base
  attr_accessible :tnuid,
                  :json,
                  :author_last_name,
                  :antcat_author_id,
                  :journal_name,
                  :hol_journal_id,
                  :antcat_journal_id,
                  :year,
                  :hol_pub_id,
                  :start_page,
                  :end_page,
                  :antcat_protonym_id,
                  :antcat_citation_id,
                  :antcat_name_id,
                  :antcat_reference_id,
                  :antcat_taxon_id,
                  :rank,
                  :rel_type,
                  :fossil,
                  :status,
                  :valid_tnuid,
                  :name,
                  :is_valid

  # TODO move hol_id to the taxa table or migrate this to a boolean
  # DONE: copied hol_id to Taxon; this is still used in the migration.
  # TODO remove this file
  def is_valid?
    is_valid.downcase == 'valid'
  end
end
