# coding: UTF-8
module Antwiki

  def self.compare_valid show_progress = false
    Progress.new_init show_progress: show_progress, total_count: 14498
    AntwikiValidTaxon.update_all result: nil
    AntwikiValidTaxon.find_each do |antwiki_taxon|
      antwiki_name = antwiki_taxon.name
      antcat_taxon = Taxon.find_by_name antwiki_name
      if antcat_taxon.blank?
        if antwiki_taxon.year == '2012'
          antwiki_taxon.update_attribute :result, 'new'
        else
          antwiki_taxon.update_attribute :result, 'missing'
        end
      elsif antcat_taxon.status != 'valid'
        antwiki_taxon.update_attribute :result, antcat_taxon.status
      end
      Progress.tally_and_show_progress 100
    end
    Progress.show_results
    pp AntwikiValidTaxon.group(:result).count if show_progress
  end

end
