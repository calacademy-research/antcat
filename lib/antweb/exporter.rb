class Antweb::Exporter
  def initialize show_progress = false
    Progress.init show_progress
  end

  def export directory
    File.open("#{directory}/extant.xls", 'w') do |file|
      file.puts "subfamily\ttribe\tgenus\tspecies\tspecies author date\tcountry\tvalid\tavailable\tcurrent valid name\toriginal combination\ttaxonomic history"
      Taxon.all.each do |taxon|
        next if taxon.fossil?
        row = export_taxon taxon
        file.puts row.join("\t") if row
      end
    end
    Progress.show_results
  end

  def export_taxon taxon
    Progress.tally_and_show_progress 1000

    return if taxon.invalid?

    case taxon
    when Subfamily
      convert_to_antweb_array :subfamily => taxon.name,
                              :valid? => !taxon.invalid?,
                              :taxonomic_history => CatalogFormatter.format_taxonomic_history_with_statistics(taxon)
    when Genus
      subfamily_name = taxon.subfamily.try(:name) || 'incertae_sedis'
      convert_to_antweb_array :subfamily => subfamily_name,
                              :tribe => taxon.tribe && taxon.tribe.name,
                              :genus => taxon.name,
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :taxonomic_history => CatalogFormatter.format_taxonomic_history_with_statistics(taxon)
    when Species
      return unless taxon.genus && taxon.genus.tribe && taxon.genus.tribe.subfamily
      convert_to_antweb_array :subfamily => taxon.genus.subfamily.name,
                              :tribe => taxon.genus.tribe.name,
                              :genus => taxon.genus.name,
                              :species => taxon.name,
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :taxonomic_history => CatalogFormatter.format_taxonomic_history_with_statistics(taxon)
    when Subspecies
      return unless taxon.species && taxon.species.genus && taxon.species.genus.tribe && taxon.species.genus.tribe.subfamily
      convert_to_antweb_array :subfamily => taxon.species.genus.subfamily.name,
                              :tribe => taxon.species.genus.tribe.name,
                              :genus => taxon.species.genus.name,
                              :species => "#{taxon.species.name} #{taxon.name}",
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :taxonomic_history => CatalogFormatter.format_taxonomic_history_with_statistics(taxon)
    else nil
    end
  end

  private
  def boolean_to_antweb boolean
    case boolean
    when true: 'TRUE'
    when false: 'FALSE'
    when nil: nil
    else raise
    end
  end

  def convert_to_antweb_array values
    [values[:subfamily], values[:tribe], values[:genus], values[:species], nil, nil, boolean_to_antweb(values[:valid?]), boolean_to_antweb(values[:available?]), values[:current_valid_name], nil, values[:taxonomic_history]]
  end

end
