# coding: UTF-8
class ForwardReference < ActiveRecord::Base

  def self.fixup
    all.each {|e| e.fixup}
  end

  def fixup
    source = Taxon.find source_id
    target = case source
      when Family
        Genus.create_from_fixup name: target_name, subfamily_id: nil, fossil: fossil
      when Subfamily
        Genus.create_from_fixup name: target_name, subfamily_id: source_id, fossil: fossil
      when Tribe
        Genus.create_from_fixup name: target_name, tribe_id: source_id, fossil: fossil
      when Genus
        Species.create_from_fixup name: target_name, genus_id: source_id, fossil: fossil
      else raise
      end
    source.update_attributes type_taxon: target, type_taxon_name: CatalogFormatter::fossil(target_name, fossil)
  end

end

