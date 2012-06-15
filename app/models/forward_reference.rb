# coding: UTF-8
class ForwardReference < ActiveRecord::Base

  def self.fixup
    all.each {|e| e.fixup}
  end

  def fixup
    source = Taxon.find source_id
    case source
    when Species
      senior_synonym = Taxon.find_by_name target_name
      Progress.error "Couldn't find species '#{target_name}'" unless senior_synonym
      source.update_attributes status: 'synonym', synonym_of: senior_synonym
    end
  end

end
