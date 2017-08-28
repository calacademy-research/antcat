class Exporters::AdvancedSearchExporter
  include Formatters::AdvancedSearchTextFormatter

  def initialize taxa
    @taxa = taxa
  end

  def call
    return unless taxa

    taxa.reduce('') do |content, taxon|
      content << format(taxon)
    end
  end

  private
    attr_reader :taxa
end
