namespace :antcat do
  desc "Export taxonomy list"
  task taxon_list: :environment do
    Exporters::TaxonList::Exporter.new.export
  end
end
