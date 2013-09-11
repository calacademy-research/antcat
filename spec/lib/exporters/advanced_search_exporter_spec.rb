# coding: UTF-8
require 'spec_helper'

describe Exporters::AdvancedSearchExporter do
  before do
    @reference = FactoryGirl.create :article_reference,
      title:              'Ants are my life',
      author_names:       [FactoryGirl.create(:author_name, name:'Fred')],
      journal:            (FactoryGirl.create :journal, name: 'Ants'),
      series_volume_issue:'13',
      pagination:         '12',
      citation_year:      '2011d'
  end

  it "should format the number of taxa passed in" do
    Subfamily.destroy_all
    5.times do
      taxon = create_subfamily
      taxon.protonym.authorship.update_attributes! reference: @reference
    end
    exporter = Exporters::AdvancedSearchExporter.new
    exporter.export(Subfamily.all).should have(15).lines
  end

end

