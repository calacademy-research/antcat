# coding: UTF-8
class Taxon < ActiveRecord::Base
  def self.extract_original_combinations show_progress = false
    Progress.init show_progress
    Taxon.destroy_all status: 'original combination'
    Taxon.where('type = "Species" OR type = "Subspecies"').
          where('status != "original combination"').find_each do |taxon|
      if taxon.recombination? and not Taxon.find_by_name_id taxon.protonym.name.id
        genus_epithet = taxon.protonym.name.genus_epithet
        original_genus = Genus.find_by_name genus_epithet
        unless original_genus
          Progress.puts "Original genus #{genus_epithet} not found when creating original combination for #{taxon.name}"
          next
        end
        taxon.class.create! name: taxon.protonym.name, status: 'original combination', protonym: taxon.protonym,
                            genus: original_genus, current_valid_taxon: taxon
        Progress.tally_and_show_progress 100
      end
    end
    Progress.show_results
  end

  def self.report_counts_for_genera
    for genus in Genus.order(:name_cache).all
      puts "#{genus.name_cache},#{genus.species.valid.count},#{genus.subspecies.valid.count}"
    end
    nil
  end

  def update_current_valid_taxon
    return if current_valid_taxon.present?
    return unless synonym? and senior_synonyms.count > 0
    current_valid_taxon = self.class.find_most_recent_valid_senior_synonym_for self
    update_attributes! current_valid_taxon: current_valid_taxon
  end

  def self.find_most_recent_valid_senior_synonym_for taxon
    (taxon.senior_synonyms.count - 1).downto 0 do |index|
      senior_synonym = taxon.senior_synonyms[index]
      if !senior_synonym.invalid?
        return senior_synonym
      else
        return find_most_recent_valid_senior_synonym_for senior_synonym
      end
    end
    nil
  end

  ###############################################
  def self.biogeographic_regions_for_localities
    # open Flávia's file, select all, then copy and paste into a new text document with the indicated name

    return @_biogeographic_regions_for_localities if @_biogeographic_regions_for_localities

    @_biogeographic_regions_for_localities = {}
    File.open('data/biogeographic_regions_for_localities.txt', 'r').each_line do |line|
      components = line.split "\t"
      raise line if components.size != 2
      locality = components[0].upcase.chomp.gsub(/ \d+$/, '')
      biogeographic_region = components[1].chomp
      next if biogeographic_region == 'none'
      @_biogeographic_regions_for_localities[locality] = biogeographic_region
    end
    @_biogeographic_regions_for_localities
  end

  def update_biogeographic_region_from_locality map = self.class.biogeographic_regions_for_localities
    return unless protonym.locality
    return unless region = map[protonym.locality.upcase]
    return if fossil?
    update_attributes! biogeographic_region: region
  end

  def self.update_biogeographic_regions_from_localities
    taxa = Taxon.includes(:protonym)
    replacement_count = unfound_count = 0
    Progress.init true, taxa.count
    for taxon in taxa
      success = taxon.update_biogeographic_region_from_locality
      if success then replacement_count += 1 else unfound_count += 1; end
      Progress.tally_and_show_progress 1000 do
        "#{replacement_count} replacements, #{unfound_count} not found"
      end
    end
    Progress.show_results
    Progress.puts "#{replacement_count} replacements, #{unfound_count} not found"
  end

end
