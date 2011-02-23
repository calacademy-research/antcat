class Antweb::Exporter

  def export
    Taxon.all.each do |taxon|
      export_taxon taxon
    end
  end

  def export_taxon taxon
    if taxon.kind_of? Subfamily
      convert_to_antweb_array :subfamily => taxon.name, :valid? => !taxon.invalid?, :taxonomic_history => taxon.taxonomic_history
    else
      convert_to_antweb_array :subfamily => 'Myrmicinae', :genus => 'Acalama', :valid? => false, :available? => false,
                              :current_valid_name => 'Gauromyrmex',  :taxonomic_history => taxon.taxonomic_history
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
