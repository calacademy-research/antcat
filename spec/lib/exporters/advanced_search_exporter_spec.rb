require 'spec_helper'

describe Exporters::AdvancedSearchExporter do
  before do
    @reference = create :article_reference,
      title: 'Ants are my life',
      author_names: [create(:author_name, name: 'Fred')],
      journal: create(:journal, name: 'Ants'),
      series_volume_issue: '13',
      pagination: '12',
      citation_year: '2011d'
  end

  it "formats the number of taxa passed in", pending: true do
    pending "This appears to be doing exactly what is expected. check the original to see what this text should be."
    Subfamily.destroy_all
    5.times do
      taxon = create_subfamily
      taxon.protonym.authorship.update! reference: @reference
    end
    exporter = Exporters::AdvancedSearchExporter.new
    expect(exporter.export(Subfamily.all).size).to eq 15
  end
end
