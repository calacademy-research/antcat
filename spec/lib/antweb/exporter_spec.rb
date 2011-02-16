require 'spec_helper'

describe Antweb::Exporter do
  before do
    @exporter = Antweb::Exporter.new
  end

  describe "exporting one taxon" do

    it "should export a genus that's a junior synonym" do
      gauromyrmex = Genus.create! :name => 'Gauromyrmex', :status => 'valid'
      acalama = Genus.create! :name => 'Acalama', :status => 'synonym', :synonym_of => gauromyrmex, :taxonomic_history => '<i>ACALAMA</i>', :status => 'valid'
      @exporter.export_taxon(acalama).should == ['Myrmicinae', nil, 'Acalama', nil, nil, nil, nil, 'FALSE', 'FALSE', 'Gauromyrmex', nil, '<i>ACALAMA</i>']
    end

  end

end
