# coding: UTF-8
class TaxonomicHistoryItem < ActiveRecord::Base
  belongs_to :taxon
  acts_as_list :scope => :taxon

  def update_taxt_from_editable editable_taxt
    update_attribute :taxt, Taxt.from_editable(editable_taxt)
  end

end
