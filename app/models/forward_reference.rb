# coding: UTF-8
class ForwardReference < ActiveRecord::Base

  def self.fixup
    all.each {|e| e.fixup}
  end

  def fixup
    source = Taxon.find source_id
    source.update_attribute :type_taxon, Genus.create!(:name => target_name)
  end
end
