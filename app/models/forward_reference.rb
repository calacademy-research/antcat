# coding: UTF-8
class ForwardReference < ActiveRecord::Base

  belongs_to :name
  belongs_to :fixee, class_name: 'Taxon'

  def self.fixup
    all.each {|e| e.fixup}
  end

  def fixup
    taxon_with_name = Taxon.find_by_name name.name
    Progress.error "Couldn't find species '#{name.name}' when finding senior synonym of #{fixee.name}" unless taxon_with_name
    fixee.update_attributes status: 'synonym', fixee_attribute.to_sym => taxon_with_name
  end

end
