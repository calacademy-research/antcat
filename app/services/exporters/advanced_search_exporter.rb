class Exporters::AdvancedSearchExporter
  include Service

  def initialize taxa
    @taxa = taxa
  end

  def call
    return unless taxa

    taxa.reduce('') do |content, taxon|
      content << AdvancedSearchPresenter::Text.new.format(taxon)
    end
  end

  private

    attr_reader :taxa
end
