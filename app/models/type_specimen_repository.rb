# TODO temporary solution (let's see about that, heh..) for
# https://github.com/calacademy-research/antcat/issues/183
# and https://github.com/calacademy-research/antcat/issues/207

class TypeSpecimenRepository < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  def self.unique_sorted
    Taxon.uniq.pluck(:type_specimen_repository).compact.sort
  end
end
