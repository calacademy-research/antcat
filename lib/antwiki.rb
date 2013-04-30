# coding: UTF-8
# To get data from AntWiki to compare with AntCat:
#
# 1. Download http://ants.csiro.au/Ant_Wiki/images/9/9e/AntWiki_Valid_Species.txt
# 1. Open in Excel, and save as Tab-Delimited Text
# 3. In MySql, "TRUNCATE antwiki_valid_taxa"
# 4. "LOAD DATA LOCAL INFILE '/Users/mwilden/antcat/data/antwiki/AntWiki_Valid_Species.txt' REPLACE INTO TABLE antwiki_valid_taxa FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r' IGNORE 1 LINES;"
# 5. "ALTER TABLE antwiki_valid_taxa ADD COLUMN result VARCHAR(255);"
# 6. "ALTER TABLE antwiki_valid_taxa ADD column id int(10) PRIMARY KEY AUTO_INCREMENT;"

module Antwiki

  def self.compare_valid show_progress = false
    Progress.new_init show_progress: show_progress, total_count: 14498
    AntwikiValidTaxon.update_all result: nil
    AntwikiValidTaxon.find_each do |antwiki_taxon|
      antwiki_name = antwiki_taxon.name
      antcat_taxon = Taxon.find_by_name antwiki_name
      if antcat_taxon.blank?
        if antwiki_taxon.year == '2013'
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
