# coding: UTF-8
class Antweb::Exporter
  def initialize show_progress = false
    Progress.init show_progress
  end

  def export directory
    File.open("#{directory}/bolton.txt", 'w') do |file|
      file.puts "subfamily\ttribe\tgenus\tspecies\tspecies author date\tcountry\tvalid\tavailable\tcurrent valid name\toriginal combination\tfossil\ttaxonomic history"
      file.puts formicidae
      Taxon.all.each do |taxon|
        row = export_taxon taxon
        file.puts row.join("\t") if row
      end
    end
    Progress.show_results
  end

  def formicidae
    "Formicidae\t\t\t\t\t\tTRUE\tTRUE\t\t\tFALSE\t" + Formatters::CatalogFormatter.format_statistics(Taxon.statistics, :include_invalid => false)
  end

  def export_taxon taxon
    Progress.tally_and_show_progress 1000

    return unless !taxon.invalid? || taxon.unidentifiable?

    case taxon
    when Subfamily
      convert_to_antweb_array :subfamily => taxon.name.to_s,
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :taxonomic_history => Exporters::Antweb::Formatter.format_taxonomic_history_with_statistics_for_antweb(taxon, :include_invalid => false),
                              :fossil? => taxon.fossil
    when Genus
      subfamily_name = taxon.subfamily && taxon.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = taxon.tribe && taxon.tribe.name.to_s
      convert_to_antweb_array :subfamily => subfamily_name,
                              :tribe => tribe_name,
                              :genus => taxon.name.to_s,
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :taxonomic_history => Exporters::Antweb::Formatter.format_taxonomic_history_with_statistics_for_antweb(taxon, :include_invalid => false),
                              :fossil? => taxon.fossil
    when Species
      return unless taxon.genus
      subfamily_name = taxon.genus.subfamily && taxon.genus.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = taxon.genus.tribe && taxon.genus.tribe.name.to_s
      convert_to_antweb_array :subfamily => subfamily_name,
                              :tribe => tribe_name,
                              :genus => taxon.genus.name.to_s,
                              :species => taxon.name.epithet,
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :taxonomic_history => Exporters::Antweb::Formatter.format_taxonomic_history_with_statistics_for_antweb(taxon, :include_invalid => false),
                              :fossil? => taxon.fossil
    when Subspecies
      return unless taxon.species && taxon.species.genus
      subfamily_name = taxon.species.genus.subfamily && taxon.species.genus.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = taxon.species.genus.tribe && taxon.species.genus.tribe.name.to_s
      convert_to_antweb_array :subfamily => subfamily_name,
                              :tribe => tribe_name,
                              :genus => taxon.species.genus.name.to_s,
                              :species => taxon.name.epithet,
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :taxonomic_history => Exporters::Antweb::Formatter.format_taxonomic_history_with_statistics_for_antweb(taxon, :include_invalid => false),
                              :fossil? => taxon.fossil
    else nil
    end
  end

  private
  def boolean_to_antweb boolean
    case boolean
    when true then 'TRUE'
    when false then 'FALSE'
    when nil then nil
    else raise
    end
  end

  def convert_to_antweb_array values
    [values[:subfamily], values[:tribe], values[:genus], values[:species], nil, nil, boolean_to_antweb(values[:valid?]), boolean_to_antweb(values[:available?]), values[:current_valid_name], nil, boolean_to_antweb(values[:fossil?]), values[:taxonomic_history]]
  end

end
