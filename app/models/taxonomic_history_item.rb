# coding: UTF-8
class TaxonomicHistoryItem < ActiveRecord::Base
  belongs_to :taxon
  acts_as_list :scope => :taxon

  def update_taxt_from_editable editable_taxt
    update_attribute :taxt, Taxt.from_editable(editable_taxt)
  rescue Taxt::ReferenceNotFound => e
    errors.add :base, "The reference '#{e}' could not be found. Was the ID changed by mistake?"
  end

end
