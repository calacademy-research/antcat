# coding: UTF-8
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
                  :status

end
