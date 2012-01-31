# coding: UTF-8
class ForwardReference < ActiveRecord::Base

  def self.fixup
    all.each {|e| e.fixup}
  end

  def fixup
    source = Taxon.find source_id
    rank = case source
      when Family
        'genus'
      when Subfamily
        'genus'
      when Tribe
        'genus'
      when Genus
        'species'
      when Subgenus
        'species'
      else raise
      end
    source.update_attributes type_taxon_rank: rank, type_taxon_name: CatalogFormatter::fossil(target_name, fossil)
  end

end
