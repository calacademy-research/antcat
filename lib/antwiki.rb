# coding: UTF-8
module Antwiki

  def self.compare_valid show_progress = false
    Progress.new_init show_progress: show_progress
    Progress.total_count = 14499
    results = {}
    results[:missing_from_antcat] = []
    results[:invalid_in_antcat] = []
    results[:count] = 0

    AntwikiValidTaxon.all.each do |antwiki_taxon|
      results[:count] += 1
      antcat_taxon = Taxon.find_by_name antwiki_taxon.name
      if antcat_taxon.blank?
        results[:missing_from_antcat] << antwiki_taxon.name
      elsif antcat_taxon.status != 'valid'
        results[:invalid_in_antcat] << antwiki_taxon.name
      end
      Progress.tally_and_show_progress 10
    end

    results
  end

end
