class Antweb::Exporter

  def export
    Taxon.all.each do |taxon|
      export_taxon taxon
    end
  end

  def export_taxon taxon
    ['Myrmicinae', nil, 'Acalama', nil, nil, nil, nil, 'FALSE', 'FALSE', 'Gauromyrmex', nil, '<i>ACALAMA</i>']
  end
end
