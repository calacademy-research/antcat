# coding: UTF-8
class ReferenceSection < ActiveRecord::Base
  belongs_to :taxon
  acts_as_list scope: :taxon
  has_paper_trail

  include CleanNewlines
  before_save {|record| clean_newlines record, :subtitle_taxt, :references_taxt}

  def self.dedupe
    all.each do |reference_section|
      where('references_taxt = ? AND position > ?',
        reference_section.references_taxt, reference_section.position).destroy_all
    end
  end

end
