class Antweb::Exporter
  def initialize show_progress = false

  end

  def export
    extant_file = File.open('data/output/extant.xls', 'w')
    Taxon.all.each do |taxon|
      row = export_taxon taxon
      extant_file.puts row.join("\t") if row
    end
  end

  def export_taxon taxon
    case taxon
    when Subfamily: convert_to_antweb_array :subfamily => taxon.name, :valid? => !taxon.invalid?, :taxonomic_history => taxon.taxonomic_history
    #when Genus: convert_to_antweb_array :genus => taxon.name, :valid? => !taxon.invalid?, :taxonomic_history => taxon.taxonomic_history
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
    [values[:subfamily], nil, values[:genus], nil, nil, nil, nil, boolean_to_antweb(values[:valid?]), boolean_to_antweb(values[:available?]), values[:current_valid_name], nil, values[:taxonomic_history]]
  end

end
