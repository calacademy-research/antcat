require 'spec_helper'

describe Antweb::Exporter do
  before do
    @exporter = Antweb::Exporter.new
  end

  describe "exporting one taxon" do

    it "should export extinct taxa to one file and extant taxa to another" do
      mock_extinct_file = mock File
      mock_extant_file = mock File
      File.should_receive(:open).with("foo/extinct.xls", 'w').and_return mock_extinct_file
      File.should_receive(:open).with("foo/extant.xls", 'w').and_return mock_extant_file
      extinct_taxon = mock_model Genus, :fossil? => true, :type => 'Genus'
      extant_taxon = mock_model Genus, :fossil? => false, :type => 'Genus'
      Taxon.should_receive(:all).and_return([extinct_taxon, extant_taxon])
      @exporter.should_receive(:export_taxon).with(extinct_taxon).and_return ['extinct taxon']
      @exporter.should_receive(:export_taxon).with(extant_taxon).and_return ['extant taxon']
      mock_extant_file.should_receive(:puts).with 'extant taxon'
      mock_extinct_file.should_receive(:puts).with 'extinct taxon'
      mock_extant_file.should_receive(:close)
      mock_extinct_file.should_receive(:close)
      @exporter.export 'foo'
    end

    it "should export a subfamily" do
      ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      @exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', nil, nil, nil, '<p>Ponerinae</p>']
    end

    it "should not export an extinct subfamily" do
      ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>', :fossil => true
      @exporter.export_taxon(ponerinae).should be_nil
    end

    it "should export a genus" do
      myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      dacetini = Tribe.create! :name => 'Dacetini', :subfamily => myrmicinae, :status => 'valid'
      acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :tribe => dacetini, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', 'Acanothognathus', nil, '<i>Acanthognathous</i>']
    end

    it "should simply set 'available' to equal 'valid'" do
      subfamily = Factory :subfamily
      tribe = Factory :tribe, :subfamily => subfamily
      valid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'valid'
      invalid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'syononym'
      @exporter.export_taxon(valid_genus).should == [subfamily.name, tribe.name, valid_genus.name, nil, nil, nil, 'TRUE', 'TRUE', valid_genus.name, nil, nil]
      @exporter.export_taxon(invalid_genus).should == [subfamily.name, tribe.name, invalid_genus.name, nil, nil, nil, 'FALSE', 'FALSE', invalid_genus.name, nil, nil]
    end

    #it "should export a genus that's a junior synonym" do
      #gauromyrmex = Genus.create! :name => 'Gauromyrmex', :status => 'valid'
      #acalama = Genus.create! :name => 'Acalama', :status => 'synonym', :synonym_of => gauromyrmex, :taxonomic_history => '<i>ACALAMA</i>', :status => 'valid'
      #@exporter.export_taxon(acalama).should == ['Myrmicinae', nil, 'Acalama', nil, nil, nil, nil, 'FALSE', 'FALSE', 'Gauromyrmex', nil, '<i>ACALAMA</i>']
    #end

  end

end
