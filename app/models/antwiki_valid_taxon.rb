# coding: UTF-8
class AntwikiValidTaxon < ActiveRecord::Base
  attr_accessible :name,
                  :subfamilia,
                  :tribus,
                  :genus,
                  :species,
                  :binomial,
                  :binomial_authority,
                  :subspecies,
                  :trinomial,
                  :trinomial_authority,
                  :author,
                  :year,
                  :changed_comb,
                  :type_locality_country,
                  :source,
                  :images



  self.table_name = :antwiki_valid_taxa
end
