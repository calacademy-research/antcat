# See https://github.com/calacademy-research/antcat/issues/170

class CleanupBiogeographicRegions < ActiveRecord::Migration
  def up
    puts "Start biogeographic region cleanup."

    # Problem 1: replace 'Palaearctic' --> 'Palearctic'
    palaearctics = by_region "Palaearctic"
    puts "Found #{palaearctics.count} 'Palaearctic' taxa"
    palaearctics.find_each do |taxon|
      taxon.update_columns biogeographic_region: "Palearctic"
      puts "taxon #{taxon.id}: replaced biogeographic_region 'Palaearctic' --> 'Palearctic'"
    end

    # Problem 2: replace '' --> nil
    empty_string_regions = by_region ""
    puts "Found #{empty_string_regions.count} empty_string_regions"
    empty_string_regions.find_each do |taxon|
      taxon.update_columns biogeographic_region: nil
      puts "taxon #{taxon.id}: replaced biogeographic_region '' --> nil"
    end

    # Problem 3: Only species and subspecies should have a biogeographic region
    Taxon.where.not(type: ["Species", "Subspecies"])
        .where.not(biogeographic_region: ["", nil]).find_each do |taxon|
      taxon.update_columns biogeographic_region: nil
      puts "taxon #{taxon.id}: replaced biogeographic_region '#{taxon.biogeographic_region}' --> nil"
    end

    puts "Done. Stats after replacements:"
    puts "  #{by_region('Palaearctic').count} 'Palaearctic' taxa"
    puts "  #{by_region('').count} empty_string_regions taxa"
  end

  def down
    puts "not restoring invalid biogeogaphic regions" # not worth the effort
  end

  def by_region region
    Taxon.where(biogeographic_region: region)
  end
end
