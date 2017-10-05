# TODO let's use this before we have a proper model, like `TypeSpecimenRepository`.

class Locality < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  def self.unique_sorted
    Protonym.uniq.pluck(:locality).compact.sort
  end
end
