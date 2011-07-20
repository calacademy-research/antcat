require 'spec_helper'

describe AuthorityList::Exporter do
  before do
    @exporter = AuthorityList::Exporter.new
  end

  it "should write its output to the right file" do
    File.should_receive(:open).with 'data/output/antcat_authority_list.txt', 'w'
    @exporter.export 'data/output'
  end

  it "should include the correct header" do
    file = stub
    File.stub(:open).and_yield file
    file.should_receive(:puts).with "subfamily\ttribe\tgenus\tspecies\tsubspecies\tstatus\tfossil"
    @exporter.export 'data/output'
  end

  describe "Outputting taxa" do
    before do
      @subfamily = Factory :subfamily, :name => 'Myrmicinae'
      @tribe = Factory :tribe, :name => 'Attini', :subfamily => @subfamily
      @genus = Factory :genus, :name => 'Atta', :subfamily => @subfamily, :tribe => @tribe
      @species = Factory :species, :name => 'robusta', :subfamily => @subfamily, :genus => @genus
    end

    it "should export a species correctly" do
      @exporter.format_taxon(@species).should == "Myrmicinae\tAttini\tAtta\trobusta\tvalid\t"
    end

    it "should export a fossil species correctly" do
      @species.update_attribute :fossil, true
      @exporter.format_taxon(@species).should == "Myrmicinae\tAttini\tAtta\trobusta\tvalid\ttrue"
    end

    it "should not export genera (or subfamilies or tribes)" do
      @exporter.should_receive(:write).twice
      @exporter.export 'data/output'
    end

    it "should export a subspecies correctly"
    it "should sort its output by names in ranks"
  end

  #describe "exporting one taxon" do
    #it "should export a subfamily" do
      #ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      #Factory :genus, :subfamily => ponerinae, :tribe => nil
      #@exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', nil, nil, nil, '<p class="taxon_statistics">1 genus</p><p>Ponerinae</p>', nil]
    #end

    #it "should export fossil taxa" do
      #ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      #Factory :genus, :subfamily => ponerinae, :tribe => nil
      #fossil = Factory :genus, :subfamily => ponerinae, :tribe => nil, :fossil => true, :name => 'Atta', :taxonomic_history => 'Atta'
      #@exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', nil, nil, nil, '<p class="taxon_statistics">Extant: 1 genus</p><p class="taxon_statistics">Fossil: 1 genus</p><p>Ponerinae</p>', nil]
      #@exporter.export_taxon(fossil).should == ['Ponerinae', nil, 'Atta', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'Atta', 'TRUE']
    #end

    #it "should export a genus" do
      #myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      #dacetini = Tribe.create! :name => 'Dacetini', :subfamily => myrmicinae, :status => 'valid'
      #acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :tribe => dacetini, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      #CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(acanthognathus, :include_invalid => false).and_return 'history'
      #@exporter.export_taxon(acanthognathus).should == ['Myrmicinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'history', nil]
    #end

    #it "should export a genus without a tribe" do
      #myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      #acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      #CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(acanthognathus, :include_invalid => false).and_return 'history'
      #@exporter.export_taxon(acanthognathus).should == ['Myrmicinae', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'history', nil]
    #end

    #it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      #acanthognathus = Genus.create! :name => 'Acanothognathus', :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      #CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(acanthognathus, :include_invalid => false).and_return 'history'
      #@exporter.export_taxon(acanthognathus).should == ['incertae_sedis', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'history', nil]
    #end

    #it "should not export invalid taxa" do
      #subfamily = Factory :subfamily
      #tribe = Factory :tribe, :subfamily => subfamily
      #valid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'valid'
      #invalid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'syononym'
      #CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(valid_genus, :include_invalid => false).and_return 'history'
      #CatalogFormatter.should_not_receive(:format_taxonomic_history_with_statistics).with(invalid_genus, :include_invalid => false)
      #@exporter.export_taxon(valid_genus).should == [subfamily.name, tribe.name, valid_genus.name, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'history', nil]
      #@exporter.export_taxon(invalid_genus).should == nil
    #end

    #it "should not export an invalid taxon" do
      #acalama = Factory :genus,  :status => 'synonym'
      #CatalogFormatter.should_not_receive(:format_taxonomic_history_with_statistics)
      #@exporter.export_taxon(acalama).should == nil
    #end

    #describe "Exporting species" do

      #it "should export one correctly" do
        #myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        #attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
        #atta = Factory :genus, :name => 'Atta', :tribe => attini
        #species = Factory :species, :name => 'robustus', :genus => atta, :taxonomic_history => 'Taxonomic history'
        #CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(species, :include_invalid => false).and_return 'history'
        #@exporter.export_taxon(species).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'history', nil]
      #end

    #end

    #describe "Exporting subspecies" do

      #it "should export one correctly" do
        #myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        #attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
        #atta = Factory :genus, :name => 'Atta', :tribe => attini
        #species = Factory :species, :name => 'robustus', :genus => atta
        #subspecies = Factory :subspecies, :name => 'emeryii', :species => species, :taxonomic_history => 'Taxonomic history'
        #CatalogFormatter.should_receive(:format_taxonomic_history_with_statistics).with(subspecies, :include_invalid => false).and_return 'history'
        #@exporter.export_taxon(subspecies).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'history', nil]
      #end

    #end
  #end
end
