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

  it "should format a taxon" do
    subfamily = create_subfamily 'Dolichoderinae'
    subfamily.protonym.authorship.update_attributes! reference: @reference
    subfamily.update_attributes! incertae_sedis_in: :family
    exporter = Exporters::AdvancedSearchExporter.new
    exporter.export([subfamily]).should == %{Dolichoderinae <i>incertae sedis</i> in family\nFred 2011d. Ants are my life. Ants 13:12.\n}
  end

end

