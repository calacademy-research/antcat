class Exporters::AdvancedSearchExporter
  include Formatters::AdvancedSearchTextFormatter

  def export taxa
    return unless taxa
    taxa.inject('') do |content, taxon|
      content << format(taxon)
    end
  end

end
