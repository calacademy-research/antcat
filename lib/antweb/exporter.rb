class Antweb::Exporter
  def initialize show_progress = false
  end

  def export directory
    extant_file = File.open("#{directory}/extant.xls", 'w')
    extinct_file = File.open("#{directory}/extinct.xls", 'w')
    Taxon.all.each do |taxon|
      row = export_taxon taxon
      file = taxon.fossil? ? extinct_file : extant_file
      file.puts row.join("\t") if row
    end
    extinct_file.close
    extant_file.close
  end

  def export_taxon taxon
    case taxon
    when Subfamily
      taxon.fossil? ? nil : convert_to_antweb_array(:subfamily => taxon.name, :valid? => !taxon.invalid?, :taxonomic_history => taxon.taxonomic_history)
    when Genus
      return nil unless taxon.subfamily && taxon.tribe
      convert_to_antweb_array :subfamily => taxon.subfamily.name,
                              :tribe => taxon.tribe.name,
                              :genus => taxon.name,
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :current_valid_name => taxon.current_valid_name,
                              :taxonomic_history => taxon.taxonomic_history
    when Species
      return nil unless taxon.genus && taxon.genus.tribe && taxon.genus.tribe.subfamily
      convert_to_antweb_array :subfamily => taxon.genus.subfamily.name,
                              :tribe => taxon.genus.tribe.name,
                              :genus => taxon.genus.name,
                              :species => taxon.name,
                              :valid? => !taxon.invalid?, :available? => !taxon.invalid?,
                              :taxonomic_history => taxon.taxonomic_history
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
