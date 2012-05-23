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
      when Species
        senior_synonym = Taxon.find_by_genus_id_and_name target_parent, target_name
        Progress.error "Couldn't find species '#{target_name}' for genus #{target_parent}" unless senior_synonym
        source.update_attributes status: 'synonym', synonym_of: senior_synonym
        return
      else raise
      end
    source.update_attributes type_taxon_rank: rank, type_taxon_name: Formatters::CatalogFormatter::fossil(target_name, fossil)
  end

end
