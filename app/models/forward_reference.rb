# coding: UTF-8
class ForwardReference < ActiveRecord::Base

  def self.fixup
    all.each {|e| e.fixup}
  end

  def fixup
    source = Taxon.find source_id
    target = case source
    when Family then Genus
    when Genus then Species
    else raise
    end.create! :name => target_name, :status => 'valid'
    source.update_attribute :type_taxon, target
  end
end
