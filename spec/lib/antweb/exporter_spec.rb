require 'spec_helper'

describe Antweb::Exporter do
  before do
    @exporter = Antweb::Exporter.new
  end

  describe "export" do
    it "should call its export_taxon on each Taxon" do
      Taxon.should_receive(:all).and_return [:a, :b, :c]
      @exporter.should_receive(:export_taxon).with(:a)
      @exporter.should_receive(:export_taxon).with(:b)
      @exporter.should_receive(:export_taxon).with(:c)
      @exporter.export
    end
  end

  describe "exporting one taxon" do

    it "should export a subfamily" do
      ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      @exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, nil, 'TRUE', nil, nil, nil, '<p>Ponerinae</p>']
    end

    #it "should export a genus that's a junior synonym" do
      #gauromyrmex = Genus.create! :name => 'Gauromyrmex', :status => 'valid'
      #acalama = Genus.create! :name => 'Acalama', :status => 'synonym', :synonym_of => gauromyrmex, :taxonomic_history => '<i>ACALAMA</i>', :status => 'valid'
      #@exporter.export_taxon(acalama).should == ['Myrmicinae', nil, 'Acalama', nil, nil, nil, nil, 'FALSE', 'FALSE', 'Gauromyrmex', nil, '<i>ACALAMA</i>']
    #end

  end

end
